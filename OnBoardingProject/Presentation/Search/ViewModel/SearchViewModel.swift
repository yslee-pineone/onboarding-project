//
//  SearchViewModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

import RxSwift
import RxCocoa

class SearchViewModel {
    let model: SearchModel
    let nowSearchData = BehaviorRelay<[BookData]>(value: [])
    let bag = DisposeBag()
    
    var nowPage = 1
    
    struct Input {
        let searchText: Observable<String>
        let nextDisplayIndex: Observable<IndexPath>
    }
    
    struct Output {
        let cellData: Driver<[BookData]>
    }
    
    func transform(input: Input) -> Output {
        input.searchText
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMapLatest { viewModel, query in
                viewModel.nowPage = 1
                return viewModel.model.bookListSearch(query: query, nextPage: "\(viewModel.nowPage)")
            }
            .bind(to: self.nowSearchData)
            .disposed(by: self.bag)
        
        input.nextDisplayIndex
            .withUnretained(self)
            .filter { viewModel, index in
                (viewModel.nowPage * 8) - 3 <= (index.section * 8) + index.row
            }
            .withLatestFrom(input.searchText)
            .withUnretained(self)
            .flatMapLatest { viewModel, query in
                viewModel.nowPage += 1
                return viewModel.model.bookListSearch(query: query, nextPage: "\(viewModel.nowPage)")
            }
            .withUnretained(self)
            .map { viewModel, newData in
                var list = viewModel.nowSearchData.value
                list.append(contentsOf: newData)
                
                return list
            }
            .bind(to: self.nowSearchData)
            .disposed(by: self.bag)
        
        return Output(
            cellData: nowSearchData
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model: SearchModel = .init()
    ) {
        self.model = model
    }
}
