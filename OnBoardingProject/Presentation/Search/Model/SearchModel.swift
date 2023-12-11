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
}
