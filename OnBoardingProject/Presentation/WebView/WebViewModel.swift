//
//  WebViewModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/11/23.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow

enum WebViewActionType {
    
}

class WebViewModel: Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        AppStep.webViewIsRequired(title: bookTitle, url: bookURL)
    }
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = WebViewModel
    
    private let bookTitle: String
    private let bookURL: URL?
    
    struct Input {
        let actionTrigger: Observable<WebViewActionType>
    }
    
    struct Output {
        let loadingURL: Observable<URL?>
        let title: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            loadingURL: .just(bookURL),
            title: .just(bookTitle)
        )
    }
    
    init(
        title: String,
        bookURL: URL?
    ){
        self.bookTitle = title
        self.bookURL = bookURL
    }
}
