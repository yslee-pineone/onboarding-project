//
//  MainViewModel.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow
import NSObject_Rx
import Action

enum MainViewActionType {
    case refreshEvent
    case browserIconTap(book: BookData)
    case cellTap(bookID: String)
}

class MainViewModel: NSObject, Stepper, ViewModelType {
    
    // MARK: - Stepper
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        AppStep.mainIsRequired
    }
    
    // MARK: - ViewModelType Protocol
    
    typealias ViewModel = MainViewModel
    
    private let nowCellData = BehaviorRelay<[BookData]>(value: [])
    private let cellDataLoading = Action<Void, [BookData]> { _ in
        BookListLoad.newBookListRequest()
    }
    private let nowErrorMsg = Action<NetworkingError, String> {
        .just($0.errorMSG)
    }
    
    struct Input {
        let actionTrigger: Observable<MainViewActionType>
    }
    
    struct Output {
        let cellData: Observable<[BookData]>
        let errorMsg: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        input.actionTrigger
            .bind(onNext: actionProcess)
            .disposed(by: rx.disposeBag)
        
        return Output(
            cellData: nowCellData
                .asObservable(),
            errorMsg: nowErrorMsg
                .elements
        )
    }
    
    private func actionProcess(_ type: MainViewActionType) {
        switch type {
        case .refreshEvent:
            cellDataLoading.execute(())
                .subscribe(onNext: { [weak self] data in
                    self?.nowCellData.accept(data)
                    
                },onError: {[weak self] error in
                    self?.nowCellData.accept([])
                    
                    guard let error = error as? ActionError,
                          case .underlyingError(let oneError) = error,
                          let networkingError = oneError as? NetworkingError
                    else {
                        self?.nowErrorMsg.execute(.defaultError)
                        return
                    }
                    
                    self?.nowErrorMsg.execute(networkingError)
                })
                .disposed(by: rx.disposeBag)
            
        case .browserIconTap(let bookData):
            steps.accept(AppStep.webViewIsRequired(title: bookData.mainTitle, url: bookData.bookURL))
            
        case .cellTap(let bookID):
            steps.accept(AppStep.detailIsRequired(id: bookID))
        }
    }
    
    override init(
        
    ) {
        super.init()
        // 초기 로딩 시도
        actionProcess(.refreshEvent)
    }
}
