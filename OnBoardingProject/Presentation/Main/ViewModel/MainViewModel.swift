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
    let model: MainModel
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
                viewModel.model.newBookLoad()
            }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.nowCellData.accept(data)
            }, onError: { [weak self] error in
                print(error)
                self?.nowCellData.accept([])
            })
            .disposed(by: bag)
        
        return Output(
            cellData: self.nowCellData
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model: MainModel = .init()
    ) {
        self.model = model
    }
}
