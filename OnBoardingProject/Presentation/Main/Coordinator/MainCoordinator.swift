//
//  MainCoordinator.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

class MainCoordinator: CoordinatorProtocol {
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
        let viewModel = MainViewModel()
        let mainVC = MainVC(viewModel: viewModel)
        self.navigationController.pushViewController(mainVC, animated: true)
    }
}
