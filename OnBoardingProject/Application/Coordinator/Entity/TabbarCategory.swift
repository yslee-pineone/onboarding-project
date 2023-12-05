//
//  TabbarCategory.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

enum TabbarCategory: String, CaseIterable {
    case new = "New"
    case search = "Search"
    
    var icon: UIImage? {
        switch self {
        case .new:
            UIImage(systemName: "book")
        case .search:
            UIImage(systemName: "magnifyingglass")
        }
    }
    
    var title: String {
        self.rawValue
    }
    
    var number: Int {
        switch self {
        case .new:
            0
        case .search:
            1
        }
    }
}
