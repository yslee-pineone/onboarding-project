//
//  MainViewModel.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

class MainViewModel: NSObject {
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
                BookListLoad.newBookListRequest()
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
            .disposed(by: rx.disposeBag)
        
        return Output(
            cellData: self.nowCellData
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    override init(
      
    ) {
        
    }
}
