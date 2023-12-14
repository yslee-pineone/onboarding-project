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
    
    static func newBookListRequest() -> Single<Result<[BookData], Error>> {
        return BookListLoad.networkService.request(
            configuration: .new,
            decodingType: BookListData.self
        )
        .map {.success($0.books)}
        .catch {.just(.failure($0))}
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
    ) -> Single<Result<BookListData, Error>> {
        return BookListLoad.searchBookListRequest(query: query, page: page)
            .map {.success($0)}
            .catch {.just(.failure($0))}
    }
    
}
