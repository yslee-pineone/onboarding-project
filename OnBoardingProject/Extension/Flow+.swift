//
//  Flow+.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import UIKit
import RxFlow

extension Flow {
    func detailPush(id: String, navigationController: UINavigationController) -> FlowContributors {
        let detailViewModel = DetailViewModel(id: id)
        let detailFlow = DetailFlow(navigationController: navigationController, viewModel: detailViewModel)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: detailFlow,
            withNextStepper: detailViewModel
        ))
    }
    
    func webViewPush(title: String, url: URL?, navigationController: UINavigationController) -> FlowContributors {
        let webViewModel = WebViewModel(title: title, bookURL: url)
        let webViewFlow = WebViewFlow(navigationController: navigationController, viewModel: webViewModel)
        
        return .one(flowContributor: .contribute(
            withNextPresentable: webViewFlow,
            withNextStepper: webViewModel
        ))
    }
}
