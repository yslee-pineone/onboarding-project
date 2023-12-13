//
//  UserDefaultService.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/13/23.
//

import Foundation

import RxSwift

class UserDefaultService {
    static func memoRequest(bookID id: String) -> Single<String> {
        return Single<String>.create { single in
            if let contents = UserDefaults.standard.string(forKey: id) {
                single(.success(contents))
            } else {
                single(.failure(UserDefaultError.notContents))
            }
            
            return Disposables.create()
        }
    }
    
    static func memoSave(bookID id:String, contents: String) {
        return UserDefaults.standard.setValue(contents, forKey: id)
    }
    
    static func searchWordSave(keywordList: [String]) {
        if UserDefaultService.isAutoSave() {
            UserDefaults.standard.setValue(
                keywordList,
                forKey: "SearchWordSave"
            )
        }
    }
    
    static func searchWordRequest() -> Single<[String]> {
        return Single<[String]>.create { single in
            if UserDefaultService.isAutoSave() {
                if let contents = UserDefaults.standard.object(forKey: "SearchWordSave") as? [String],
                   !contents.isEmpty
                {
                    single(.success(contents))
                } else {
                    single(.failure(UserDefaultError.notContents))
                }
            } else {
                single(.failure(UserDefaultError.searchWordSaveOff))
            }
            return Disposables.create()
        }
    }
    
    // 처음 값이 설정이 되어 있지 않을 때에도 true가 나와야 하기 때문에 !를 붙여서 사용
    static func isAutoSave() -> Bool {
        return !UserDefaults.standard.bool(forKey: "SearchWordSaveOff")
    }
    
    static func isAutoSaveValueSet(on: Bool) {
        UserDefaults.standard.setValue(!on, forKey: "SearchWordSaveOff")
    }
}
