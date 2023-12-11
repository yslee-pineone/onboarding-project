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
           
        Observable.merge(searchResult, nextResult)
            .withUnretained(self)
            .map { viewModel, newData in
                var list = viewModel.nowSearchData.value
                
                if case let .success(successData) = newData {
                    if successData.page == "1" {
                        return successData.books
                    } else {
                        list.append(contentsOf: successData.books)
                        return list
                    }
                }
                if case .failure(let error) = newData {
                    let urlError = error as? NetworkingError
                    print(error, urlError)
                    
                    switch urlError {
                    case .error_400, .error_401, .error_499:
                        return list
                    default:
                        return []
                    }
                }
                return list
            }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.nowSearchData.accept(data)
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
