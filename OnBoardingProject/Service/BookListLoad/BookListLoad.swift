//
//  BookListLoad.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation
import RxSwift
import RxCocoa

class BookListLoad {
    private static let networkService: NetworkServiceProtocol = NetworkService()
    
    static func newBookListRequest() -> Single<[BookData]> {
        return BookListLoad.networkService.request(
            configuration: .new,
            decodingType: BookListData.self
        )
        .map {$0.books}
    }
    
    static func searchBookListRequest(query: String, page: String) -> Single<BookListData> {
        return BookListLoad.networkService.request(
            configuration: .search(query: query, page: page),
            decodingType: BookListData.self
        )
    }
    
    static func detailBookInfomationRequest(id: String) -> Single<BookData> {
        return BookListLoad.networkService.request(
            configuration: .detail(id: id),
            decodingType: BookData.self
        )
    }
    
    static func bookListSearch(
        query: String, nextPage page: String
    ) -> Single<BookListData> {
        return BookListLoad.searchBookListRequest(query: query, page: page)
    }
}
