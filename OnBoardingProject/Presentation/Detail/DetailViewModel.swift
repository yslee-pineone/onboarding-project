//
//  DetailViewModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow
import NSObject_Rx
import Action

enum DetailViewActionType {
    case didDisappearMemoContents(memo: String)
    case browserIconTap(book: BookData?)
    case errorPopupOkBtnTap
}

class DetailViewModel: NSObject, Stepper, ViewModelType {
    
    // MARK: - Stepper
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        AppStep.detailIsRequired(id: bookID)
    }
    
    // MARK: - ViewModelType Protocol
    
    typealias ViewModel = DetailViewModel
    
    private let bookID: String
    private let nowBookData = Action<String, BookData> {
        BookListLoad.detailBookInfomationRequest(id: $0)
    }
    
    private let errorTitle = PublishSubject<String>()
    
    struct Input {
        let actionTrigger: Observable<DetailViewActionType>
    }
    
    struct Output {
        let bookData: Observable<BookData>
        let memoData: Observable<String>
        let errorMSG: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        // transform 호출 후 바로 값을 보내게 되면 Observable이 놓칠 수 있기 때문에 0.1초 뒤에 발송
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.nowBookData.execute("\(self.bookID)")
        }
        
        nowBookData
            .executionObservables
            .flatMap{$0}
            .subscribe(onError: { [weak self] error in
                let networkingError = error as? NetworkingError
                
                guard let self = self else {return}
                self.errorTitle.onNext(networkingError?.errorMSG ??  NetworkingError.defaultErrorMSG)
            })
            .disposed(by: rx.disposeBag)
        
        input.actionTrigger
            .bind(onNext: actionProcess)
            .disposed(by: rx.disposeBag)
        
        return Output(
            bookData: nowBookData
                .elements
                .asObservable(),
            memoData: UserDefaultService.memoRequest(bookID: bookID)
                .catchAndReturn("")
                .asObservable(),
            errorMSG: errorTitle
                .asObservable()
        )
    }
    
    private func actionProcess(_ actionType: DetailViewActionType) {
        switch actionType {
        case .browserIconTap(let bookData):
            guard let bookData = bookData else {return}
            steps.accept(AppStep.webViewIsRequired(title: bookData.mainTitle, url: bookData.bookURL))
            
        case .didDisappearMemoContents(let contents):
            UserDefaultService.memoSave(
                bookID: bookID,
                contents: contents == DefaultMSG.Detail.memoPlaceHolder ? "" : contents
            )
            
        case .errorPopupOkBtnTap:
            steps.accept(AppStep.detailComlete)
        }
    }
    
    init(
        id: String
    ) {
        self.bookID = id
    }
}
