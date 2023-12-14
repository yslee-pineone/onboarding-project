//
//  BookListLoadCategory.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import Foundation

enum BookListLoadCategory {
    case search(query: String, page: String)
    case new
    case detail(id: String)
}
