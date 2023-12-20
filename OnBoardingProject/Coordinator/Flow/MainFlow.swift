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
    let navigationController = UINavigationController()
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
            
        case .detailIsRequired(let bookID):
            return detailPush(id: bookID)
            
        default:
            return .none
        }
    }
    
    private func detailPush(id: String) -> FlowContributors {
        let detailViewModel = DetailViewModel(id: id)
        let detailFlow = DetailFlow(navigationController: navigationController, viewModel: detailViewModel)
        
        return .one(flowContributor:
                .contribute(
                    withNextPresentable: detailFlow,
                    withNextStepper: detailViewModel
                )
        )
    }
}
