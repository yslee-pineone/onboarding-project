//
//  SearchModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

import RxSwift

class SearchModel {
    let bookListLoad: BookListLoad
    
    init(
        bookListLoad: BookListLoad = .init()
    ) {
        self.bookListLoad = bookListLoad
    }
    
    func bookListSearch(
        query: String, nextPage page: String
    ) -> Single<Result<BookListData, Error>> {
        return bookListLoad.searchBookListRequest(query: query, page: page)
            .map {.success($0)}
            .catch {.just(.failure($0))}
    }
    
    func searchWordSave(keywordList: [String]) {
        if !UserDefaults.standard.bool(forKey: "SearchWordSaveOff") {
            UserDefaults.standard.setValue(
                keywordList,
                forKey: "SearchWordSave"
            )
        }
    }
    
    func searchWordRequest() -> Single<[String]> {
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
