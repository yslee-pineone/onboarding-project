//
//  TabbarController.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/7/23.
//

import UIKit

class TabbarController: UITabBarController {
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nil, bundle: nil)
        tabbarSet()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tabbarSet() {
        let navigations = TabbarCategory.allCases.map { [weak self] category in
            self?.createNavigationController(category: category) ?? UINavigationController()
        }
        
        setViewControllers(navigations, animated: true)
    }
    
    func createTabbarItem(category: TabbarCategory) -> UITabBarItem {
        UITabBarItem(title: category.title, image: category.icon, tag: category.number)
    }
    
    func createNavigationController(category: TabbarCategory) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = createTabbarItem(category: category)
        
        switch category {
        case .new:
            let mainViewModel = MainViewModel()
            navigationController.pushViewController(MainViewController(viewModel: mainViewModel), animated: true)
            
        case .search:
            let searchViewModel = SearchViewModel()
            navigationController.pushViewController(SearchViewController(viewModel: searchViewModel), animated: true)
            break
        }
        
        return navigationController
    }
}
