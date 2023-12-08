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
    
    func newBookListRequest() -> Observable<BookListData> {
        let urlComponents = self.setURLComponents(category: .new)
       
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
    }
    
    func searchBookListRequest(query: String, page: String) -> Observable<BookListData> {
        let urlComponents = self.setURLComponents(
            category: .search(query: query, page: page)
        )
     
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
    }
    
    func detailBookInfomationRequest(id: String) -> Observable<BookData> {
        let urlComponents = self.setURLComponents(
            category: .detail(id: id)
        )
        return self.networkService.request(
            urlComponents: urlComponents,
            decodingType: BookData.self
        )
        .map { data in
            guard case .success(let value) = data else {
                print("DATA LOADING ERROR")
                return BookData(
                    mainTitle: DefaultMSG.Error.defaultError,
                    subTitle: DefaultMSG.Error.defaultError,
                    bookID: "-1",
                    price: DefaultMSG.Error.defaultError,
                    imageString: DefaultMSG.Error.defaultError,
                    urlString: DefaultMSG.Error.defaultError
                )
            }
            return value
        }
    }
    
    private func setURLComponents(category: BookListLoadCategory) -> URLComponents {
        var urlComponents = URLComponents()
        urlComponents.scheme = URLRequestConfiguration.URL.scheme.rawValue
        urlComponents.host = URLRequestConfiguration.URL.host.rawValue
        
        switch category {
        case .detail(let id):
            urlComponents.path = URLRequestConfiguration.Detail.path.queryAdd(id: id)
        case .new:
            urlComponents.path = URLRequestConfiguration.New.path.rawValue
        case .search(let query, let page):
            urlComponents.path = URLRequestConfiguration.Search.path.queryAdd(query: query, page: page)
        }
        
        return urlComponents
    }
}
