//
//  DetailViewModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

enum DetailViewActionType {
    case didDisappearMemoContents(memo: String)
    case browserIconTap(book: BookData?)
}

class DetailViewModel: NSObject {
    private let bookID: String
    private let nowBookData = BehaviorRelay<BookData>(
        value: .init(
            error: DefaultMSG.Detail.loading,
            mainTitle: DefaultMSG.Detail.loading,
            subTitle: DefaultMSG.Detail.loading,
            bookID: DefaultMSG.Detail.loading,
            price: DefaultMSG.Detail.loading,
            imageString: DefaultMSG.Detail.loading,
            urlString: DefaultMSG.Detail.loading
        )
    )
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
        BookListLoad.detailBookInfomationRequest(id: bookID)
            .asObservable()
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.nowBookData.accept(data)
            }, onError: { [weak self] error in
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
        case .browserIconTap(let bookID):
            break
        case .didDisappearMemoContents(let contents):
            UserDefaultService.memoSave(
                bookID: bookID,
                contents: contents == DefaultMSG.Detail.memoPlaceHolder ? "" : contents
            )
        }
    }
    
    init(
        id: String
    ) {
        self.bookID = id
    }
}
