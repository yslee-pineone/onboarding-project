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
        let searchResult = input.searchText
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMapLatest { viewModel, query in
                viewModel.nowPage = 1
                return viewModel.model.bookListSearch(query: query, nextPage: "\(viewModel.nowPage)")
            }
        
        let nextResult = input.nextDisplayIndex
            .withUnretained(self)
            .filter { viewModel, index in
                (viewModel.nowPage * 10) - 3 <= (index.section * 10) + index.row
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
        
        Observable.merge(searchResult, nextResult)
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.nowSearchData.accept(data)
            }, onError: { [weak self] error in
                print(error)
                self?.nowSearchData.accept([])
            })
            .disposed(by: bag)
        
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
