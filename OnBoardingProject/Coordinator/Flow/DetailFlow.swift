//
//  DetailFlow.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow

class DetailFlow: Flow {
    let navigationController: UINavigationController
    let viewModel: DetailViewModel
    var root: RxFlow.Presentable {
        return navigationController
    }
    
    init(
        navigationController: UINavigationController,
        viewModel: DetailViewModel
    ) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppStep else {return .none}
        
        switch step {
        case .detailIsRequired:
            let vc = DetailViewController(viewModel: viewModel)
            vc.hidesBottomBarWhenPushed = true
            
            navigationController.pushViewController(vc, animated: true)
            
            return .none
            
        case .webViewIsRequired(let title, let url):
            return webViewPush(title: title, url: url, navigationController: navigationController)
            
        default:
            return .none
        }
    }
}
