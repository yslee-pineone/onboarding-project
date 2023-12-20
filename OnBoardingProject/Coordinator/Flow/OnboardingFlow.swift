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
            var tabbarVC = root
            tabbarVC[0].tabBarItem = UITabBarItem(
                title: TabbarCategory.new.title,
                image: TabbarCategory.new.icon,
                tag: TabbarCategory.new.number
            )
            
            tabbarVC[1].tabBarItem = UITabBarItem(
                title: TabbarCategory.search.title,
                image: TabbarCategory.search.icon,
                tag: TabbarCategory.search.number
            )
            
            self?.tabbarController.setViewControllers(tabbarVC, animated: true)
        }
        
        return .multiple(flowContributors: [
            .contribute(withNextPresentable: mainFlow, withNextStepper: mainViewModel),
            .contribute(withNextPresentable: searchFlow, withNextStepper: searchViewModel)
        ])
    }
}
