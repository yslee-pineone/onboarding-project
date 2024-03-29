//
//  OnboardingFlow.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow

class OnboardingFlow: Flow {
    lazy var tabbarController = UITabBarController()
    var root: RxFlow.Presentable {
        return tabbarController
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppStep else {return .none}
        
        switch step {
        case .onboardingIsRequired:
            return onboardingSet()
            
        default:
            return .none
        }
    }
    
    private func onboardingSet() -> FlowContributors {
        let mainViewModel = MainViewModel()
        let mainFlow = MainFlow(viewModel: mainViewModel)
        
        let searchViewModel = SearchViewModel()
        let searchFlow = SearchFlow(viewModel: searchViewModel)
        
        Flows.use([mainFlow, searchFlow], when: .created) { [weak self] root in
            let tabbarVC = root
            
            tabbarVC[0].tabBarItem = TabbarCategory.new.tabbarItem
            tabbarVC[1].tabBarItem = TabbarCategory.search.tabbarItem
            
            self?.tabbarController.setViewControllers(tabbarVC, animated: true)
        }
        
        return .multiple(flowContributors: [
            .contribute(withNextPresentable: mainFlow, withNextStepper: mainViewModel),
            .contribute(withNextPresentable: searchFlow, withNextStepper: searchViewModel)
        ])
    }
}
