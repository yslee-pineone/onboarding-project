//
//  DetailModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

import RxSwift

class DetailModel {
    let networkService: NetworkServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.networkService = networkService
    }
    
    func detailBookDataRequest(id: String) -> Observable<BookData> {
        var urlComponents = URLComponents()
        urlComponents.scheme = URLRequestConfiguration.URL.scheme.rawValue
        urlComponents.host = URLRequestConfiguration.URL.host.rawValue
        urlComponents.path = URLRequestConfiguration.Detail.path.queryAdd(id: id)
        
        return self.networkService.request(
            urlComponents: urlComponents,
            decodingType: BookData.self
        )
        .map { data in
            guard case .success(let value) = data else {
                print("DATA LOADING ERROR")
                return BookData(
                    title: "문제가 발생했습니다.",
                    subtitle: "문제가 발생했습니다.",
                    isbn13: "-1",
                    price: "문제가 발생했습니다.",
                    image: "문제가 발생했습니다.",
                    url: "문제가 발생했습니다."
                )
            }
            return value
        }
        .asObservable()
    }
}
