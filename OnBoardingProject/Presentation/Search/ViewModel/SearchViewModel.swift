//
//  SearchViewModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

import RxSwift
import RxCocoa
import NSObject_Rx

class SearchViewModel: NSObject {
    let model: SearchModel
    let bag = DisposeBag()
    
    let nowSearchData = BehaviorRelay<[BookData]>(value: [])
    let nowSaveWords = BehaviorRelay<[String]>(value: [])
    
    var nowPage = 1
    
    struct Input {
        let searchText: Observable<String>
        let nextDisplayIndex: Observable<IndexPath>
        let enterTap: Observable<Void>
        let saveCellTap: Observable<String>
    }
    
    struct Output {
        let cellData: Driver<[BookData]>
        let saveCellData: Driver<[String]>
        let saveCellErrorMSG: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let searchText = Observable
            .merge(
                input.searchText
                    .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance),
                input.saveCellTap
            )
        
        let searchResult = searchText
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
                    case .error_400, .error_499, .error_500:
                        return []
                    default:
                        return list
                    }
                }
                return list
            }
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                viewModel.nowSearchData.accept(data)
            })
            .disposed(by: rx.disposeBag)
        
        input.enterTap
            .withLatestFrom(input.searchText)
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                var now = viewModel.nowSaveWords.value
                now.append(data)
                
                viewModel.model.searchWordSave(keywordList: now)
                viewModel.nowSaveWords.accept(now)
            })
            .disposed(by: rx.disposeBag)
        
        let saveSearchWord = model.searchWordRequest()
        
        saveSearchWord
            .catchAndReturn([])
            .asObservable()
            .bind(to: nowSaveWords)
            .disposed(by: rx.disposeBag)
        
        return Output(
            cellData: nowSearchData
                .asDriver(onErrorDriveWith: .empty()),
            saveCellData: nowSaveWords
                .asDriver(onErrorDriveWith: .empty()),
            saveCellErrorMSG: saveSearchWord
                .filter {$0.isEmpty}
                .map {_ in ""}
                .catch { error in
                    let userDefaultError = error as? UserDefaultError
                    
                    return .just(userDefaultError?.errorMSG ?? UserDefaultError.defaultErrorMSG)
                }
                .asDriver(onErrorDriveWith: .empty())
        )
    }
    
    init(
        model: SearchModel = .init()
    ) {
        self.model = model
    }
}
