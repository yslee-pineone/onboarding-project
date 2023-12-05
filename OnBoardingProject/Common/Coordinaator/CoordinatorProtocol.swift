//
//  CoordinatorProtocol.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

protocol CoordinatorProtocol {
    var navigationController: UINavigationController { get set }
    var childCoordinator: [CoordinatorProtocol] { get set }
    
    func start()
}
