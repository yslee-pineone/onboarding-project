//
//  AppFlow.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow

class AppFlow: Flow {
    var window: UIWindow
    var root: RxFlow.Presentable {
        return window
    }
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func navigate(to step: RxFlow.Step) -> RxFlow.FlowContributors {
        guard let step = step as? AppStep else {return .none}
        
        switch step {
        case .onboardingIsRequired:
            let oneStepper = OneStepper(withSingleStep: AppStep.onboardingIsRequired)
            let onboardingFlow = OnboardingFlow()
            
            Flows.use(onboardingFlow, when: .created) { [weak self] root in
                self?.window.rootViewController = root
            }
            
            return .one(
                flowContributor: .contribute(
                    withNextPresentable: onboardingFlow,
                    withNextStepper: oneStepper
                )
            )
            
        default:
            return .none
        }
    }
}
