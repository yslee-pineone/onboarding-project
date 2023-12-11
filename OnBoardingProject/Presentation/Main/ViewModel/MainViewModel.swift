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
                if case .success(let value) = data {
                    viewModel.nowCellData.accept(value)
                }
                
                if case .failure(let error) = data {
                    viewModel.nowCellData.accept([])
                    print(error)
                }
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
