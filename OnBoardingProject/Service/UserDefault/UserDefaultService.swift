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
        return userDefaultRequest(
            key: UserDefaultCategory.memo(id: id).key, type: String.self
        )
    }
    
    static func memoSave(bookID id:String, contents: String) {
        userDefaultSave(value: contents, key: id)
    }
    
    static func searchWordSave(keywordList: [String]) {
        if !UserDefaultService.isAutoSave() {return}
        userDefaultSave(value: keywordList, key: UserDefaultCategory.searchKeyword.key)
    }
    
    static func searchWordRequest() -> Single<[String]> {
        return userDefaultRequest(key: UserDefaultCategory.searchKeyword.key, type: [String].self)
            .map {
                if !UserDefaultService.isAutoSave() {
                    throw UserDefaultError.searchWordSaveOff
                }else if $0.isEmpty {
                    throw UserDefaultError.notContents
                } else {
                    return $0
                }
            }
    }
    
    // 처음 값이 설정이 되어 있지 않을 때에도 true가 나와야 하기 때문에 !를 붙여서 사용
    static func isAutoSave() -> Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaultCategory.searchWordIsSave.key)
    }
    
    static func isAutoSaveValueSet(on: Bool) {
        userDefaultSave(value: !on, key: UserDefaultCategory.searchWordIsSave.key)
    }
    
    private static func userDefaultSave(value: Any, key: String) {
        UserDefaults.standard.setValue(value, forKey: key)
    }
    
    private static func userDefaultRequest<T>(key: String, type: T.Type) -> Single<T> {
        return Single<T>.create { single in
            if let contents = UserDefaults.standard.object(forKey: key),
               let data = contents as? T
            {
                single(.success(data))
            } else {
                single(.failure(UserDefaultError.notContents))
            }
            
            return Disposables.create()
        }
    }
}
