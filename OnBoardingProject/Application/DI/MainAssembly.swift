//
//  MainAssembly.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

import Swinject

struct MainAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(MainViewModel.self) { _ in
            MainViewModel()
        }
        
        container.register(MainVC.self) { container in
            MainVC(viewModel: container.resolve(MainViewModel.self)!)
        }
    }
}
