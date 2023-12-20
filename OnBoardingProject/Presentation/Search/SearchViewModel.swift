//
//  SearchViewModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation
import RxSwift
import RxCocoa
import RxFlow
import NSObject_Rx

enum SearchViewActionType {
    case searchText(text: String)
    case nextDisplayIndex(index: IndexPath)
    case enterTap
    case saveCellTap(word: String, row: Int)
    case settingMenuTap(category: SearchWordSaveViewSettingCategory)
    case editModeDone
    case cellTap(bookID: String)
    case browserIconTap(book: BookData)
    case settingTap
}

class SearchViewModel: NSObject, Stepper {
    // MARK: - Stepper
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        AppStep.searchIsRequired
    }
    
    // MARK: - ViewModelType Protocol
    typealias ViewModel = MainViewModel
    
    private let nowSearchData = BehaviorRelay<[BookData]>(value: [])
    private let nowSaveWords = BehaviorRelay<[SearchKeywordSection]>(value: [])
    private let nowKeywordAutoSave = BehaviorRelay<Bool>(value: false)
    private let nowCellErrorMSG = BehaviorRelay<String>(value: "")
    private let nowSearchKeyword = BehaviorRelay<(String, Int, Bool)>(value: ("", 0, false))
    
    struct Input {
        let actionTrigger: Observable<SearchViewActionType>
    }
    
    struct Output {
        let cellData: Observable<[BookData]>
        let saveCellData: Observable<[SearchKeywordSection]>
        let saveCellErrorMSG: Observable<String>
        let isSearchKeywordSave: Observable<Bool>
        let saveKeywordSearch: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        saveKeywordLoad()
        bookLoad()
        
        input.actionTrigger
            .bind(onNext: actionProcess)
            .disposed(by: rx.disposeBag)

        return Output(
            cellData: nowSearchData
                .asObservable(),
            saveCellData: nowSaveWords
                .asObservable(),
            saveCellErrorMSG: nowCellErrorMSG
                .asObservable(),
            isSearchKeywordSave: nowKeywordAutoSave
                .asObservable(),
            saveKeywordSearch: nowSearchKeyword
                .filter {$0.2}
                .map {$0.0}
        )
    }
    
    private func actionProcess(_ type: SearchViewActionType) {
        switch type {
        case .browserIconTap(let bookData):
            steps.accept(AppStep.webViewIsRequired(title: bookData.mainTitle, url: bookData.bookURL))
            
        case .cellTap(let bookID):
            steps.accept(AppStep.detailIsRequired(id: bookID))
            
        case .settingTap:
            break
            
        case .editModeDone:
            Observable.just(Void())
                .withLatestFrom(nowSaveWords)
                .map { data in
                    [SearchKeywordSection(items: data.first!.items, isEdit: false)]
                }
                .bind(to: nowSaveWords)
                .disposed(by: rx.disposeBag)
            
        case .enterTap:
            Observable.just(Void())
                .withLatestFrom(nowKeywordAutoSave)
                .filter {$0}
                .withLatestFrom(nowSearchKeyword)
                .withUnretained(self)
                .subscribe(onNext: { viewModel, data in
                    var now = viewModel.nowSaveWords.value.first!
                    var items = now.items
                    items.append(data.0)
                    now.items = items
                    
                    viewModel.nowSaveWords.accept([now])
                    UserDefaultService.searchWordSave(keywordList: items)
                })
                .disposed(by: rx.disposeBag)
            
        case .nextDisplayIndex(let index):
            Observable.just(Void())
                .withLatestFrom(nowSearchKeyword)
                .filter { data in
                    (data.1 * 10) - 3 <= (index.section * 10) + index.row
                }
                .map {($0.0, $0.1 + 1, $0.2)}
                .bind(to: nowSearchKeyword)
                .disposed(by: rx.disposeBag)
            
        case .saveCellTap(let word, let row):
            Observable.just((word, row))
                .withLatestFrom(nowSaveWords) { tap, now -> (String, Int)? in
                    if !now.first!.isEdit {
                        return tap
                    } else {
                        return nil
                    }
                }
                .filter {$0 != nil}
                .map {($0!.0, 1, true)}
                .bind(to: nowSearchKeyword)
                .disposed(by: rx.disposeBag)
            
            // edit mode
            Observable.just((word, row))
                .withLatestFrom(nowSaveWords)
                .filter {$0.first!.isEdit}
                .withUnretained(self)
                .subscribe(onNext: { viewModel, _ in
                    var now = viewModel.nowSaveWords.value.first!
                    var items = now.items
                    
                    items.remove(at: row)
                    now.items = items
                    
                    viewModel.nowSaveWords.accept([now])
                    UserDefaultService.searchWordSave(keywordList: items)
                })
                .disposed(by: rx.disposeBag)
            
        case .searchText(let text):
            Observable.just(text)
                .map {($0, 1, false)}
                .bind(to: nowSearchKeyword)
                .disposed(by: rx.disposeBag)
            
        case .settingMenuTap(let category):
            Observable.just(category)
                .withUnretained(self)
                .subscribe(onNext: { viewModel, type in
                    viewModel.settingMenuTap(type)
                })
                .disposed(by: rx.disposeBag)
        }
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
    
    private func settingMenuTap(_ category: SearchWordSaveViewSettingCategory) {
        switch category {
        case .saveStart, .saveStop:
            let isOn = category == .saveStart
            if !isOn {
                nowSaveWords.accept([SearchKeywordSection(items: [], isEdit: false)])
            }
            
            UserDefaultService.isAutoSaveValueSet(on: isOn)
            nowKeywordAutoSave.accept(isOn)
            
        case .wordAllRemove:
            nowSaveWords.accept([SearchKeywordSection(items: [], isEdit: false)])
            UserDefaultService.searchWordSave(keywordList: [])
            
        case .wordRemove:
            Observable.just(Void())
                .withLatestFrom(nowSaveWords)
                .map { data in
                    [SearchKeywordSection(items: data.first!.items, isEdit: true)]
                }
                .bind(to: nowSaveWords)
                .disposed(by: rx.disposeBag)
        }
        
        Observable<String>.create { observer in
            switch category {
            case .saveStart, .wordAllRemove, .wordRemove:
                observer.onNext(UserDefaultError.notContents.errorMSG)
            case .saveStop:
                observer.onNext(UserDefaultError.searchWordSaveOff.errorMSG)
            }
            
            return Disposables.create()
        }
        .bind(to: nowCellErrorMSG)
        .disposed(by: rx.disposeBag)
        
    }
    
    private func bookLoad() {
        nowSearchKeyword
            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .withUnretained(self)
            .flatMapLatest { viewModel, query in
                return BookListLoad.bookListSearch(query: query.0, nextPage: "\(query.1)")
            }
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
