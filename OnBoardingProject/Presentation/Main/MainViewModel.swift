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

enum MainViewActionType {
    case refreshEvent
    case browserIconTap(book: BookData)
    case cellTap(bookID: String)
}

class MainViewModel: NSObject, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        AppStep.mainIsRequired
    }
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = MainViewModel
    
    private let nowCellData = BehaviorRelay<[BookData]>(value: [])
    
    struct Input {
        let actionTrigger: Observable<MainViewActionType>
    }
    
    struct Output {
        let cellData: Observable<[BookData]>
    }
    
    func transform(input: Input) -> Output {
        input.actionTrigger
            .bind(onNext: actionProcess)
            .disposed(by: rx.disposeBag)
        
        return Output(
            cellData: self.nowCellData
                .asObservable()
        )
    }
    
    private func actionProcess(_ type: MainViewActionType) {
        switch type {
        case .refreshEvent:
            BookListLoad.newBookListRequest()
                .asObservable()
                .withUnretained(self)
                .subscribe(onNext: { viewModel, data in
                    switch data {
                    case .success(let value):
                        viewModel.nowCellData.accept(value)
                        
                    case .failure(let error):
                        viewModel.nowCellData.accept([])
                        print(error)
                    }
                })
                .disposed(by: rx.disposeBag)
            
        case .browserIconTap(let bookData):
            Observable.just(bookData)
                .map {
                    AppStep.webViewIsRequired(title: $0.mainTitle, url: $0.bookURL)
                }
                .bind(to: steps)
                .disposed(by: rx.disposeBag)
            
        case .cellTap(let bookID):
            Observable.just(bookID)
                .map {
                    AppStep.detailIsRequired(id: $0)
                }
                .bind(to: steps)
                .disposed(by: rx.disposeBag)
        }
    }
    
    override init(
        
    ) {
        
    }
}
