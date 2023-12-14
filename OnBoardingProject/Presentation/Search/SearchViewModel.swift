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
    private let nowSearchData = BehaviorRelay<[BookData]>(value: [])
    private let nowSaveWords = BehaviorRelay<[SearchKeywordSection]>(value: [])
    private let nowKeywordAutoSave = BehaviorRelay<Bool>(value: false)
    private let nowCellErrorMSG = BehaviorRelay<String>(value: "")
    
    private var nowPage = 1
    
    struct Input {
        let searchText: Observable<String>
        let nextDisplayIndex: Observable<IndexPath>
        let enterTap: Observable<Void>
        let saveCellTap: Observable<(String, Int)>
        let settingMenuTap: Observable<SearchWordSaveViewSettingCategory>
        let editModeDoneTap: Observable<Void>
    }
    
    struct Output {
        let cellData: Observable<[BookData]>
        let saveCellData: Observable<[SearchKeywordSection]>
        let saveCellErrorMSG: Observable<String>
        let isSearchKeywordSave: Observable<Bool>
    }
    
    func transform(input: Input) -> Output {
        bookLoad(input)
        settingMenuTap(input)
        saveKeywordLoad()
        
        input.enterTap
            .withLatestFrom(nowKeywordAutoSave)
            .filter {$0}
            .withLatestFrom(input.searchText)
            .withUnretained(self)
            .subscribe(onNext: { viewModel, data in
                var now = viewModel.nowSaveWords.value.first!
                var items = now.items
                items.append(data)
                now.items = items
                
                viewModel.nowSaveWords.accept([now])
                UserDefaultService.searchWordSave(keywordList: items)
            })
            .disposed(by: rx.disposeBag)
        
        return Output(
            cellData: nowSearchData
                .asObservable(),
            saveCellData: nowSaveWords
                .asObservable(),
            saveCellErrorMSG: nowCellErrorMSG
                .asObservable(),
            isSearchKeywordSave: nowKeywordAutoSave
                .asObservable()
        )
    }
    
    private func saveKeywordLoad() {
        nowKeywordAutoSave.accept(UserDefaultService.isAutoSave())
        
        let saveSearchWord = UserDefaultService.searchWordRequest()
            .asObservable()
        
        saveSearchWord
            .catchAndReturn([])
            .map {
                [SearchKeywordSection(items: $0, isEdit: false)]
            }
            .bind(to: nowSaveWords)
            .disposed(by: rx.disposeBag)
        
        saveSearchWord
            .filter {$0.isEmpty}
            .map {_ in ""}
            .catch { error in
                let userDefaultError = error as? UserDefaultError
                
                return .just(userDefaultError?.errorMSG ?? UserDefaultError.defaultErrorMSG)
            }
            .bind(to: nowCellErrorMSG)
            .disposed(by: rx.disposeBag)
    }
    
    private func settingMenuTap(_ input: Input) {
        input.settingMenuTap.filter {$0 == .saveStart || $0 == .saveStop}
            .map {$0 == .saveStart}
            .withUnretained(self)
            .subscribe(onNext: { viewModel, isOn in
                if !isOn {
                    viewModel.nowSaveWords.accept([SearchKeywordSection(items: [], isEdit: false)])
                }
                
                UserDefaultService.isAutoSaveValueSet(on: isOn)
                viewModel.nowKeywordAutoSave.accept(isOn)
            })
            .disposed(by: rx.disposeBag)
        
        input.settingMenuTap.filter {$0 == .wordAllRemove}
            .withUnretained(self)
            .subscribe(onNext: { viewModel, _ in
                viewModel.nowSaveWords.accept([SearchKeywordSection(items: [], isEdit: false)])
                UserDefaultService.searchWordSave(keywordList: [])
            })
            .disposed(by: rx.disposeBag)
        
        input.settingMenuTap.filter {$0 == .wordRemove}
            .withLatestFrom(nowSaveWords)
            .map { data in
                [SearchKeywordSection(items: data.first!.items, isEdit: true)]
            }
            .bind(to: nowSaveWords)
            .disposed(by: rx.disposeBag)
        
        input.saveCellTap
            .withLatestFrom(nowSaveWords) { cellTapData, saveData -> Int? in
                if saveData.first!.isEdit {
                    return cellTapData.1
                } else {
                    return nil
                }
            }
            .filter {$0 != nil}
            .map {$0!}
            .withUnretained(self)
            .subscribe(onNext: { viewModel, row in
                var now = viewModel.nowSaveWords.value.first!
                var items = now.items
                
                items.remove(at: row)
                now.items = items
                
                viewModel.nowSaveWords.accept([now])
                UserDefaultService.searchWordSave(keywordList: items)
            })
            .disposed(by: rx.disposeBag)
        
        input.editModeDoneTap
            .withLatestFrom(nowSaveWords)
            .map { data in
                [SearchKeywordSection(items: data.first!.items, isEdit: false)]
            }
            .bind(to: nowSaveWords)
            .disposed(by: rx.disposeBag)
        
        input.settingMenuTap.map {
            switch $0 {
            case .saveStart, .wordAllRemove:
                return UserDefaultError.notContents.errorMSG
            case .saveStop:
                return UserDefaultError.searchWordSaveOff.errorMSG
            default:
                return ""
            }
        }
        .bind(to: nowCellErrorMSG)
        .disposed(by: rx.disposeBag)
    }
    
    private func bookLoad(_ input: Input) {
        let searchText = Observable
            .merge(
                input.searchText
                    .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance),
                input.saveCellTap
                    .withLatestFrom(nowSaveWords) { cellTapData, saveData -> String? in
                        if saveData.first!.isEdit {
                            return nil
                        } else {
                            return cellTapData.0
                        }
                    }
                    .filter {$0 != nil}
                    .map {$0!}
            )
        
        let searchResult = searchText
            .distinctUntilChanged()
            .withUnretained(self)
            .flatMapLatest { viewModel, query in
                viewModel.nowPage = 1
                return BookListLoad.bookListSearch(query: query, nextPage: "\(viewModel.nowPage)")
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
                return BookListLoad.bookListSearch(query: query, nextPage: "\(viewModel.nowPage)")
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
                    
                    switch urlError {
                    case .error_400, .error_499, .error_500:
                        return []
                    default:
                        return list
                    }
                }
                return list
            }
            .bind(to: nowSearchData)
            .disposed(by: rx.disposeBag)
    }
    
    override init(
        
    ) {
        
    }
}
