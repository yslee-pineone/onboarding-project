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
    
    let nowBookData = BehaviorRelay<BookData>(value: .init(title: "로딩 중", subtitle: "로딩 중", isbn13: "로딩 중", price: "로딩 중", image: "로딩 중", url: "로딩 중"))
    
    let bag = DisposeBag()
    
    struct Input {
        let viewDidDisappear: Observable<Void>
    }
    
    struct Output {
        let bookData: Driver<BookData>
    }
    
    func transform(input: Input) -> Output {
        self.model.detailBookDataRequest(id: self.bookID)
            .bind(to: self.nowBookData)
            .disposed(by: self.bag)
        
        return Output(
            bookData: self.nowBookData
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
