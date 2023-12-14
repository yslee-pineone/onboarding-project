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
        case .search(let query, let page):
            return "/1.0/search/\(query)/\(page)"
        case .detail(let id):
            return "/1.0/books/\(id)"
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
