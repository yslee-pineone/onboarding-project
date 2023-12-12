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
    let networkService: NetworkServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.networkService = networkService
    }
    
    func newBookListRequest() -> Single<BookListData> {
        return self.networkService.request(
            configuration: .new,
            decodingType: BookListData.self
        )
    }
    
    func searchBookListRequest(query: String, page: String) -> Single<BookListData> {
        return self.networkService.request(
            configuration: .search(query: query, page: page),
            decodingType: BookListData.self
        )
    }
    
    func detailBookInfomationRequest(id: String) -> Single<BookData> {
        return self.networkService.request(
            configuration: .detail(id: id),
            decodingType: BookData.self
        )
    }
}
