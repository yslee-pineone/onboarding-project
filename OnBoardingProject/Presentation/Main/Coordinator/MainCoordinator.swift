//
//  MainCoordinator.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

import Swinject

class MainCoordinator: CoordinatorProtocol {
    let dependency: Dependency
    var navigationController: UINavigationController
    var childCoordinator: [CoordinatorProtocol] = []
    
    struct Dependency {
        let navigationController: UINavigationController
        let container: Container
        let mainVC: MainVC
    }
    
    init(
        dependency: Dependency
    ) {
        self.dependency = dependency
        self.navigationController = dependency.navigationController
    }
    
    func start() {
        self.navigationController.pushViewController(self.dependency.mainVC, animated: true)
    }
}
