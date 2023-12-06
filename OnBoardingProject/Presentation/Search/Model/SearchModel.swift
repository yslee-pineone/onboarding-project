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
    
    func bookListSearch(query: String, nextPage page: String) -> Observable<[BookData]> {
        self.bookListLoad.searchBookListRequest(query: query, page: page)
            .map {$0.books}
    }
}
