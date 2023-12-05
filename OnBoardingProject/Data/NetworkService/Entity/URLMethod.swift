//
//  URLMethod.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

enum URLMethod: String {
    case get = "GET"
    
    var methodText: String {
        self.rawValue
    }
}
