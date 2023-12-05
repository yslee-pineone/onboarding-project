//
//  AppCoordinator.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

import Swinject

class AppCoordinator: CoordinatorProtocol {
    let dependency: Dependency
    var navigationController: UINavigationController
    var childCoordinator: [CoordinatorProtocol] = []
    
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
        let dependency = TabbarCoordinator.Dependency(navigationController: self.navigationController,
                                                      container: self.dependency.container
        )
        
        let tabbarCoordinator = TabbarCoordinator(dependency: dependency)
        tabbarCoordinator.start()
        
        self.childCoordinator.append(tabbarCoordinator)
    }
}
