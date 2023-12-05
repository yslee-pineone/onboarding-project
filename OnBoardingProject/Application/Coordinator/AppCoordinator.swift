//
//  AppCoordinator.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

class AppCoordinator: CoordinatorProtocol {
    let dependency: Dependency
    var navigationController: UINavigationController
    var childCoordinator: [CoordinatorProtocol] = []
    
    struct Dependency {
        let navigationController: UINavigationController
    }
    
    init(
        dependency: Dependency
    ) {
        self.dependency = dependency
        self.navigationController = dependency.navigationController
    }
    
    func start() {
        let dependency = TabbarCoordinator.Dependency(
            navigationController: self.navigationController
        )
        
        let tabbarCoordinator = TabbarCoordinator(dependency: dependency)
        tabbarCoordinator.start()
        
        self.childCoordinator.append(tabbarCoordinator)
    }
}
