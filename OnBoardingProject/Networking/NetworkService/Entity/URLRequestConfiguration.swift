//
//  URLRequestConfiguration.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

enum URLRequestConfiguration {
    enum URL: String {
        case scheme = "https"
        case host = "api.itbook.store"
    }
    
    enum New: String {
        case path = "/1.0/new"
    }
    
    enum Search: String {
        case path = "/1.0/search"
        
        func queryAdd(query: String, page: String) -> String {
            self.rawValue + "/" + query + "/" + page
        }
    }
    
    enum Detail: String {
        case path = "/1.0/book"
    }
}
