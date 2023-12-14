//
//  URLRequestConfiguration.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

import Moya

enum URLRequestConfiguration {
    static let baseURL = "https://api.itbook.store"
    
    case new
    case search(query: String, page: String)
    case detail(id: String)
}

extension URLRequestConfiguration: TargetType {
    var baseURL: URL {
        URL(string: URLRequestConfiguration.baseURL)!
    }
    
    var path: String {
        switch self {
        case .new:
            return "/1.0/new"
        case let .search(query, page):
            return "/1.0/search"  + "/" + query + "/" + page
        case let .detail(id):
            return "/1.0/books" + "/" + id
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return nil
    }
}
