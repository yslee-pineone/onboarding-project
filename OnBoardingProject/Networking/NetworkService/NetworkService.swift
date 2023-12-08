//
//  NetworkService.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

import Alamofire

import RxSwift
import RxCocoa

class NetworkService: NetworkServiceProtocol {
    func request<T: Decodable>(
        urlComponents: URLComponents,
        decodingType: T.Type
    ) -> Single<T>{
        guard let url = urlComponents.url else {
            return .error(NetworkingError.error_900)
        }
        
        return Single.create { observer -> Disposable in
           AF.request(url, method: .get)
                .responseDecodable(of: decodingType.self) { data in
                    switch data.result {
                    case .success(let value):
                        observer(.success(value))
                    case .failure(let error):
                        observer(.failure(error))
                    }
                }
            return Disposables.create()
        }
            
    }
}
