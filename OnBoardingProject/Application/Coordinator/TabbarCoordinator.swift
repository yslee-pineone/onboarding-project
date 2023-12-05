//
//  TabbarCoordinator.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

import Swinject

class TabbarCoordinator: CoordinatorProtocol {
    let dependency: Dependency
    var navigationController: UINavigationController
    var childCoordinator: [CoordinatorProtocol] = []
    var tabbarController: UITabBarController = .init()
    
    struct Dependency {
        let navigationController: UINavigationController
        let container: Container
    }
    
    init(
        dependency: Dependency
    ) {
        self.dependency = dependency
        self.navigationController = dependency.navigationController
    }
    
    func start() {
        let navigations = TabbarCategory.allCases.map {[weak self] category in
            self?.createNavigationController(category: category) ?? UINavigationController()
        }
    
        self.tabbarController.setViewControllers(navigations, animated: false)
        self.navigationController.pushViewController(self.tabbarController, animated: false)
    }
}
 
private extension TabbarCoordinator {
    func createTabbarItem(category: TabbarCategory) -> UITabBarItem {
        UITabBarItem(title: category.title, image: category.icon, tag: category.number)
    }
    
    func createNavigationController(category: TabbarCategory) -> UINavigationController {
        let navigationController = UINavigationController()
        navigationController.tabBarItem = self.createTabbarItem(category: category)
        self.startTabbarCategoryCoordinator(category: category, navigationController: navigationController)
        
        return navigationController
    }
    
    func startTabbarCategoryCoordinator(category: TabbarCategory, navigationController: UINavigationController) {
        switch category {
        case .new:
            let vc = self.dependency.container.resolve(MainVC.self)!
            let dependency = MainCoordinator.Dependency(
                navigationController: navigationController,
                container: self.dependency.container,
                mainVC: vc
            )
            
            let coordinator = MainCoordinator(dependency: dependency)
            coordinator.start()
            
            self.childCoordinator.append(coordinator)
            break
        case .search:
            break
        }
    }
}
