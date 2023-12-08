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
            mainTitle: DefaultMSG.Detail.loading,
            subTitle: DefaultMSG.Detail.loading,
            bookID: DefaultMSG.Detail.loading,
            price: DefaultMSG.Detail.loading,
            imageString: DefaultMSG.Detail.loading,
            urlString: DefaultMSG.Detail.loading
        )
    )
    
    let bag = DisposeBag()
    
    struct Input {
        let didDisappearMemoContents: Observable<String>
    }
    
    struct Output {
        let bookData: Driver<BookData>
        let memoData: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        model.detailBookDataRequest(id: bookID)
            .bind(to: nowBookData)
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
                .asDriver(onErrorJustReturn: "")
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
