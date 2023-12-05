//
//  BookListLoadProtocol.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

import RxSwift

protocol BookListLoadProtocol {
    func newBookListRequest() -> Observable<BookListData>
    func searchBookListRequest(query: String, page: String) -> Observable<BookListData>
}
