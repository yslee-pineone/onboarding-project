//
//  BookListLoad.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

import RxSwift
import RxCocoa

class BookListLoad: BookListLoadProtocol {
    let networkService: NetworkServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol
    ) {
        self.networkService = networkService
    }
    
    func newBookListRequest() -> Observable<BookListData> {
        let urlComponents = self.setURLComponents(query: nil, page: nil)
     
        return self.networkService.request(
            urlComponents: urlComponents,
            decodingType: BookListData.self
        )
        .map { data in
            guard case .success(let value) = data else {
                print("DATA LOADING ERROR")
                return BookListData(page: "-1", books: [])
            }
            return value
        }
        .asObservable()
    }
    
    func searchBookListRequest(query: String, page: String) -> Observable<BookListData> {
        let urlComponents = self.setURLComponents(query: query, page: page)
     
        return self.networkService.request(
            urlComponents: urlComponents,
            decodingType: BookListData.self
        )
        .map { data in
            guard case .success(let value) = data else {
                print("DATA LOADING ERROR")
                return BookListData(page: "-1", books: [])
            }
            return value
        }
        .asObservable()
    }
}

private extension BookListLoad {
    func setURLComponents(query: String?, page: String?) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = URLRequestConfiguration.URL.scheme.rawValue
        urlComponents.host = URLRequestConfiguration.URL.host.rawValue
        
        if query == nil && page == nil {
            urlComponents.path = URLRequestConfiguration.New.path.rawValue
        } else {
            urlComponents.path = URLRequestConfiguration.Search.path.queryAdd(query: query!, page: page!)
        }
        
        return urlComponents
    }
}
