//
//  TabbarCategory.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

enum TabbarCategory: String {
    case new = "New"
    case search = "Search"
    
    var tabbarItem: UITabBarItem {
        switch self {
        case .new:
            return UITabBarItem(title: self.rawValue, image: UIImage(systemName: "book"), tag: 0)
            
        case .search:
            return UITabBarItem(title: self.rawValue, image: UIImage(systemName: "magnifyingglass"), tag: 1)
        }
    }
}
