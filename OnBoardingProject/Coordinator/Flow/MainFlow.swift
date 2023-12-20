//
//  MainFlow.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow

class MainFlow: Flow {
    var navigationController = UINavigationController()
    var root: RxFlow.Presentable {
        return navigationController
    }
    let viewModel: MainViewModel
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppStep else {return .none}
        
        switch step {
        case .mainIsRequired:
            let vc = MainViewController(viewModel: viewModel)
            navigationController.pushViewController(vc, animated: true)
            
            return .none
            
        default:
            return .none
        }
    }
}
