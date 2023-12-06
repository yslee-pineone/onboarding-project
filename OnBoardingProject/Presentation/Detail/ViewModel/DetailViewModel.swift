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
            mainTitle: DefaultMSG.Detail.loading.rawValue,
            subTitle: DefaultMSG.Detail.loading.rawValue,
            bookID: DefaultMSG.Detail.loading.rawValue,
            price: DefaultMSG.Detail.loading.rawValue,
            imageString: DefaultMSG.Detail.loading.rawValue,
            urlString: DefaultMSG.Detail.loading.rawValue
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
        self.model.detailBookDataRequest(id: self.bookID)
            .bind(to: self.nowBookData)
            .disposed(by: self.bag)
        
        input.didDisappearMemoContents
            .withUnretained(self)
            .subscribe(onNext: { viewModel, contents in
                viewModel.model.memoSave(bookID: viewModel.bookID, contents: contents)
            })
            .disposed(by: self.bag)
        
        return Output(
            bookData: self.nowBookData
                .asDriver(onErrorDriveWith: .empty()),
            memoData: self.model.memoRequest(bookID: self.bookID)
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
