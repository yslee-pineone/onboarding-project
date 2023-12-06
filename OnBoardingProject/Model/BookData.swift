//
//  BookData.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

struct BookData: Decodable{
    let mainTitle: String
    let subTitle: String
    let bookID: String
    let price: String
    let imageString: String
    let urlString: String
    
    enum CodingKeys: String, CodingKey {
        case mainTitle = "title"
        case subTitle = "subtitle"
        case bookID = "isbn13"
        case price = "price"
        case imageString = "image"
        case urlString = "url"
    }
    
    var imageURL: URL? {
        URL(string: self.imageString)
    }
}
