//
//  SearchFlow.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow

class SearchFlow: Flow {
    let navigationController = UINavigationController()
    var root: RxFlow.Presentable {
        return navigationController
    }
    let viewModel: SearchViewModel
    
    init(viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppStep else {return .none}
        
        switch step {
        case .searchIsRequired:
            let vc = SearchViewController(viewModel: viewModel)
            navigationController.pushViewController(vc, animated: true)
            
            return .none
            
        case .detailIsRequired(let bookID):
            return detailPush(id: bookID, navigationController: navigationController)
            
        case .webViewIsRequired(let title, let url):
            return webViewPush(title: title, url: url, navigationController: navigationController)
            
        case .webViewComplete:
            navigationController.popViewController(animated: true)
            return .none
            
        default:
            return .none
        }
    }
}
