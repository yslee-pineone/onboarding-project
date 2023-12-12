//
//  NetworkServiceProtocol.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

import RxSwift

protocol NetworkServiceProtocol {
    func request<T: Decodable>(
        configuration: URLRequestConfiguration,
        decodingType: T.Type
    ) -> Single<T>
}
