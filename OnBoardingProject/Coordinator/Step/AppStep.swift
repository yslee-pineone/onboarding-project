//
//  AppStep.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/20/23.
//

import Foundation

import RxFlow

enum AppStep: Step {
    case onboardingIsRequired
    
    case mainIsRequired
    
    case searchIsRequired
    
    case detailIsRequired(bookData: BookData)
    case detailComlete
    
    case webViewIsRequired(title: String, url: URL?)
    case webViewComplate
}
