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
        UserDefaults.standard.setValue(contents, forKey: id)
    }
    
    static func searchWordSave(keywordList: [String]) {
        if !UserDefaults.standard.bool(forKey: "SearchWordSaveOff") {
            UserDefaults.standard.setValue(
                keywordList,
                forKey: "SearchWordSave"
            )
        }
    }
    
    static func searchWordRequest() -> Single<[String]> {
        return Single<[String]>.create { single in
            if !UserDefaults.standard.bool(forKey: "SearchWordSaveOff") {
                if let contents = UserDefaults.standard.object(forKey: "SearchWordSave") as? [String]{
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
}
