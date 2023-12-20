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
    case errorPopupOkBtnTap
}

class WebViewModel: NSObject, Stepper {
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
        input.actionTrigger
            .bind(onNext: actionProcess)
            .disposed(by: rx.disposeBag)
        
        return Output(
            loadingURL: .just(bookURL),
            title: .just(bookTitle)
        )
    }
    
    private func actionProcess(_ type: WebViewActionType) {
        switch type {
        case .errorPopupOkBtnTap:
            steps.accept(AppStep.webViewComplete)
        }
    }
    
    init(
        title: String,
        bookURL: URL?
    ){
        self.bookTitle = title
        self.bookURL = bookURL
    }
}
