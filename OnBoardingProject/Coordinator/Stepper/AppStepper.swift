//
//  AppStepper.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxFlow

class AppStepper: Stepper {
    var steps: RxRelay.PublishRelay<RxFlow.Step> = .init()
    
    var initialStep: Step {
        AppStep.onboardingIsRequired
    }
}
