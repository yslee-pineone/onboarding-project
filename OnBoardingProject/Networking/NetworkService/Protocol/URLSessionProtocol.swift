//
//  URLSessionProtocol.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

import RxSwift

protocol URLSessionProtocol {
    func request(_ request: URLRequest) -> RxSwift.Observable<(response: HTTPURLResponse, data: Data)>
}
