//
//  URLSession+.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

import RxSwift
import RxCocoa

extension URLSession: URLSessionProtocol {
    func request(_ request: URLRequest) -> RxSwift.Observable<(response: HTTPURLResponse, data: Data)> {
        self.rx.response(request: request)
    }
}
