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
    
    private lazy var nowCellData = Action<Bool, [BookData]> { [weak self] isLoad in
        if isLoad {
            return BookListLoad.newBookListRequest()
        } else {
            // 로드 실패 시 return 값으로 빈 배열을 반환하기 위해 사용
            // 로드 시도 -> 실패? -> nowCellData(false)로 빈 배열 반환
            self?.nowErrorMsg.execute(.error_800)
            return .just([])
        }
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
                .elements,
            errorMsg: nowErrorMsg
                .elements
        )
    }
    
    private func actionProcess(_ type: MainViewActionType) {
        switch type {
        case .refreshEvent:
            // event를 전송하면서, Observable을 바로 사용
            nowCellData.execute(true)
                .subscribe(onError: {[weak self] error in
                    // 빈 배열 반환을 위한 재요청
                    self?.nowCellData.execute(false)
                    
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
        
    }
}
