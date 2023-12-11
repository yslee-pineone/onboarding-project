//
//  DetailViewModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

import RxSwift
import RxCocoa

class DetailViewModel {
    let model: DetailModel
    let bookID: String
    
    let nowBookData = BehaviorRelay<BookData>(
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
    
    let errorTitle = PublishSubject<String>()
    
    let bag = DisposeBag()
    
    struct Input {
        let didDisappearMemoContents: Observable<String>
    }
    
    struct Output {
        let bookData: Driver<BookData>
        let memoData: Driver<String>
        let errorMSG: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        model.detailBookDataRequest(id: bookID)
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.nowBookData.accept(data)
            }, onError: { [weak self] error in
                let networkingError = error as? NetworkingError
                
                guard let self = self else {return}
                self.errorTitle.onNext(networkingError?.errorMSG ??  NetworkingError.defaultErrorMSG)
            })
            .disposed(by: bag)
        
        input.didDisappearMemoContents
            .withUnretained(self)
            .subscribe(onNext: { viewModel, contents in
                viewModel.model.memoSave(bookID: viewModel.bookID, contents: contents)
            })
            .disposed(by: bag)
        
        return Output(
            bookData: nowBookData
                .asDriver(onErrorDriveWith: .empty()),
            memoData: model.memoRequest(bookID: bookID)
                .asDriver(onErrorJustReturn: ""),
            errorMSG: errorTitle
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model: DetailModel = .init(),
        id: String
    ) {
        self.model = model
        self.bookID = id
    }
}
