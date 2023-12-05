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
    ) -> Single<Result<T, URLError>>{
        guard let url = urlComponents.url else {return .just(.failure(.init(.badURL)))}
        
        return Observable.create { observer -> Disposable in
           AF.request(url, method: .get)
                .responseDecodable(of: decodingType.self) { data in
                    switch data.result {
                    case .success(let value):
                        observer.onNext(.success(value))
                    case .failure(let error):
                        observer.onError(error)
                    }
                }
            return Disposables.create()
        }
        .asSingle()
            
    }
}
