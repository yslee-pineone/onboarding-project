//
//  NetworkService.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation
import Moya
import RxSwift
import RxCocoa

class NetworkService: NetworkServiceProtocol {
    private let provider = MoyaProvider<URLRequestConfiguration>()
    
    func request<T: Decodable>(
        configuration: URLRequestConfiguration,
        decodingType: T.Type
    ) -> Single<T> {
        provider.rx.request(configuration)
            .map { response in
                switch response.statusCode {
                case 200 ... 299:
                    do {
                        let json = try JSONDecoder().decode(decodingType, from: response.data)
                        return json
                    } catch {
                        throw NetworkingError.error_400
                    }
                case 400 ... 499:
                    throw NetworkingError.error_499
                case 500 ... 599:
                    throw NetworkingError.error_500
                default:
                    throw NetworkingError.error_500
                }
            }
            .timeout(.seconds(3), other: .error(NetworkingError.error_999), scheduler: MainScheduler.asyncInstance)
    }
}
