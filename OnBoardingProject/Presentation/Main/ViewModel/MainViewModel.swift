//
//  MainViewModel.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

import RxSwift
import RxCocoa

class MainViewModel {
    let bookListLoad: BookListLoad
    let nowCellData = BehaviorRelay<[BookData]>(value: [])
    
    let bag = DisposeBag()
    
    struct Input {
        let refreshEvent: Observable<Void>
    }
    
    struct Output {
        let cellData: Driver<[BookData]>
    }
    
    func transform(input: Input) -> Output {
        input.refreshEvent
            .withUnretained(self)
            .flatMap { viewModel, _ in
                viewModel.bookListLoad.newBookListRequest()
            }
            .map {$0.books}
            .bind(to: self.nowCellData)
            .disposed(by: self.bag)
        
        return Output(
            cellData: self.nowCellData
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        bookListLoad: BookListLoad
    ) {
        self.bookListLoad = bookListLoad
    }
}
