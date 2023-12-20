//
//  WebViewFlow.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow

class WebViewFlow: Flow {
    let navigationController: UINavigationController
    let viewModel: WebViewModel
    var root: RxFlow.Presentable {
        return navigationController
    }
    
    init(
        navigationController: UINavigationController,
        viewModel: WebViewModel
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppStep else {return .none}
        
        switch step {
        case .webViewIsRequired:
            let vc = WebViewController(viewModel: viewModel)
            vc.hidesBottomBarWhenPushed = true
            
            navigationController.pushViewController(vc, animated: true)
            
            return .none
            
        case .webViewComplete:
            return .end(forwardToParentFlowWithStep: AppStep.webViewComplete)
            
        default:
            return .none
        }
    }
}
