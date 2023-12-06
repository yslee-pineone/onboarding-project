//
//  SceneDelegate.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
    
        let tabbarController = UITabBarController()
        
        let navigations = TabbarCategory.allCases.map { [weak self] category in
            self?.createNavigationController(category: category) ?? UINavigationController()
        }
        
        tabbarController.setViewControllers(navigations, animated: true)
        
        self.window?.rootViewController = tabbarController
        self.window?.makeKeyAndVisible()
    }
}

extension SceneDelegate {
    func createTabbarItem(category: TabbarCategory) -> UITabBarItem {
        UITabBarItem(title: category.title, image: category.icon, tag: category.number)
    }
    
    func createNavigationController(category: TabbarCategory) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = self.createTabbarItem(category: category)
        
        switch category {
        case .new:
            let mainViewModel = MainViewModel()
            navigationController.pushViewController(MainVC(viewModel: mainViewModel), animated: true)
        case .search: 
            break
        }
        
        return navigationController
    }
}
