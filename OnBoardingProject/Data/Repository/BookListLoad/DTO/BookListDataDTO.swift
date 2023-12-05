//
//  BookListDataDTO.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

struct BookListDataDTO: Decodable {
    let page: String?
    let books: [BookData]
}

struct BookData: Decodable {
    let title: String
    let subtitle: String
    let isbn13: String
    let price: String
    let image: String
    let url: String
}
