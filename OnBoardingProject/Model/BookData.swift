//
//  BookData.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

struct BookData: Decodable{
    let title: String
    let subtitle: String
    let isbn13: String
    let price: String
    let image: String
    let url: String
    
    var imageURL: URL? {
        URL(string: self.image)
    }
}
