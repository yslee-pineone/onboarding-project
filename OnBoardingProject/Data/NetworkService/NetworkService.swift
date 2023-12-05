//
//  NetworkService.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

import RxSwift
import RxCocoa

class NetworkService: NetworkServiceProtocol {
    let urlSession: URLSessionProtocol
    
    init(
        urlSession: URLSessionProtocol = URLSession.shared
    ) {
        self.urlSession = urlSession
    }
    
    func request<T: Decodable>(
        urlComponents: URLComponents,
        method: URLMethod,
        decodingType: T.Type
    ) -> Single<Result<T, URLError>>{
        guard let url = urlComponents.url else {return .just(.failure(.init(.badURL)))}
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = method.methodText
        
        return self.urlSession.request(urlRequest)
            .map { data in
                switch data.response.statusCode {
                case 200 ..< 299:
                    do {
                        let json = try JSONDecoder().decode(decodingType, from: data.data)
                        return .success(json)
                    } catch {
                        return .failure(.init(.cannotDecodeContentData))
                    }
                case 400 ..< 499:
                    return .failure(URLError(.clientCertificateRejected))
                case 500 ..< 599:
                    return .failure(.init(.badServerResponse))
                default:
                    return .failure(.init(.unknown))
                }
            }
            .asSingle()
    }
}
