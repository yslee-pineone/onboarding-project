//
//  MainModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

import RxSwift

class MainModel {
    let bookListLoad: BookListLoad
    
    init(
        bookListLoad: BookListLoad = .init()
    ) {
        self.bookListLoad = bookListLoad
    }
    
    func newBookLoad() -> Observable<[BookData]> {
        return bookListLoad.newBookListRequest()
            .map {$0.books}
            .asObservable()
    }
}
