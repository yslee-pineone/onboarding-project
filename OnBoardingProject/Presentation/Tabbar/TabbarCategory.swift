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
            return UIImage(systemName: "book")
        case .search:
            return UIImage(systemName: "magnifyingglass")
        }
    }
    
    var title: String {
        return self.rawValue
    }
    
    var number: Int {
        switch self {
        case .new:
            return 0
        case .search:
            return 1
        }
    }
}
