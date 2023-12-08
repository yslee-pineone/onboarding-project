//
//  DetailModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

import RxSwift

class DetailModel {
    let bookListLoad: BookListLoad
    
    init(
        bookListLoad: BookListLoad = .init()
    ) {
        self.bookListLoad = bookListLoad
    }
    
    func detailBookDataRequest(id: String) -> Observable<BookData> {
        return bookListLoad.detailBookInfomationRequest(id: id)
            .asObservable()
    }
    
    func memoRequest(bookID id: String) -> Single<String> {
        return Single<String>.create { single in
            if let contents = UserDefaults.standard.string(forKey: id) {
                single(.success(contents))
            } else {
                single(.failure(UserDefaultError.notContents))
            }
            
            return Disposables.create()
        }
    }
    
    func memoSave(bookID id:String, contents: String) {
        UserDefaults.standard.setValue(contents, forKey: id)
    }
}
