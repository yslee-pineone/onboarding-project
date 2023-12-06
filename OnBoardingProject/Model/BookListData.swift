//
//  BookListData.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation


struct BookListData: Decodable {
    let page: String?
    let books: [BookData]
}
