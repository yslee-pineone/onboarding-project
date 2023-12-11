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
    
    func newBookLoad() -> Single<Result<[BookData], Error>> {
        return bookListLoad.newBookListRequest()
            .map {.success($0.books)}
            .catch {.just(.failure($0))}
    }
}
