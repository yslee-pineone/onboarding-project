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
import Action

enum SearchViewActionType {
    case searchText(text: String)
    case nextDisplayIndex(index: IndexPath)
    case enterTap
    case saveCellTap(word: String, row: Int)
    case settingMenuTap(category: SearchWordSaveViewSettingCategory)
    case editModeDone
    case cellTap(bookID: String)
    case browserIconTap(book: BookData)
}

class SearchViewModel: NSObject, Stepper, ViewModelType {
    
    // MARK: - Stepper
    
    var steps = PublishRelay<Step>()
    
    var initialStep: Step {
        AppStep.searchIsRequired
    }
    
    // MARK: - ViewModelType Protocol
    
    typealias ViewModel = SearchViewModel
    
    private let nowSearchData = BehaviorRelay<[BookData]>(value: [])
    private let nowSaveWords = BehaviorRelay<[SearchKeywordSection]>(value: [])
    private let nowKeywordAutoSave = BehaviorRelay<Bool>(value: false)
    private let nowCellErrorMSG = Action<UserDefaultError, String> {
        .just($0.errorMSG)
    }
    private let nowSearchKeyword = BehaviorRelay<(String, Int, Bool)>(value: ("", 0, false))
    private let nowSearchErrorMSG = Action<NetworkingError, String> {
        .just($0.errorMSG)
    }
    
    struct Input {
        let actionTrigger: Observable<SearchViewActionType>
    }
    
    struct Output {
        let cellData: Observable<[BookData]>
        let saveCellData: Observable<[SearchKeywordSection]>
        let saveCellErrorMSG: Observable<String>
        let isSearchKeywordSave: Observable<Bool>
        let saveKeywordSearch: Observable<String>
        let searchErrorMSG: Observable<String>
    }
    
    func transform(input: Input) -> Output {
        saveKeywordLoad()
        
        input.actionTrigger
            .bind(onNext: actionProcess)
            .disposed(by: rx.disposeBag)
        
        return Output(
            cellData: nowSearchData
                .asObservable(),
            saveCellData: nowSaveWords
                .asObservable(),
            saveCellErrorMSG: nowCellErrorMSG
                .elements,
            isSearchKeywordSave: nowKeywordAutoSave
                .asObservable(),
            saveKeywordSearch: nowSearchKeyword
                .filter {$0.2}
                .map {$0.0},
            searchErrorMSG: nowSearchErrorMSG
                .elements
        )
    }
    
    private func actionProcess(_ type: SearchViewActionType) {
        switch type {
        case .browserIconTap(let bookData):
            steps.accept(AppStep.webViewIsRequired(title: bookData.mainTitle, url: bookData.bookURL))
            
        case .cellTap(let bookID):
            steps.accept(AppStep.detailIsRequired(id: bookID))
            
        case .editModeDone:
            let data = [SearchKeywordSection(items: nowSaveWords.value.first!.items, isEdit: false)]
            nowSaveWords.accept(data)
            
        case .enterTap:
            if nowKeywordAutoSave.value {
                let data = nowSearchKeyword.value
                var now = nowSaveWords.value.first!
                var items = now.items
                items.append(data.0)
                now.items = items
                
                nowSaveWords.accept([now])
                UserDefaultService.searchWordSave(keywordList: items)
            }
           
        case .nextDisplayIndex(let index):
            let nowSaveWordsValue = nowSearchKeyword.value
            
            if (nowSaveWordsValue.1 * 10) - 3 <= (index.section * 10) + index.row {
                nowSearchKeyword.accept((nowSaveWordsValue.0, nowSaveWordsValue.1 + 1, nowSaveWordsValue.2))
                bookLoad()
            }
            
        case .saveCellTap(let word, let row):
            let nowSaveWordsValue = nowSaveWords.value
            
            if !nowSaveWordsValue.first!.isEdit {
                nowSearchKeyword.accept((word, 1, true))
                bookLoad()
            } else {
                // edit mode
                var now = nowSaveWords.value.first!
                var items = now.items
                
                items.remove(at: row)
                now.items = items
                
                nowSaveWords.accept([now])
                UserDefaultService.searchWordSave(keywordList: items)
            }
            
        case .searchText(let text):
            nowSearchKeyword.accept((text, 1, false))
            bookLoad()
            
        case .settingMenuTap(let category):
            settingMenuTap(category)
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
            .delaySubscription(.milliseconds(50), scheduler: MainScheduler.asyncInstance)
            .subscribe(onError: { [weak self] error in
                let userDefaultError = error as? UserDefaultError
                self?.nowCellErrorMSG.execute(userDefaultError ?? .defaultError)
            })
            .disposed(by: rx.disposeBag)
    }
    
    private func settingMenuTap(_ category: SearchWordSaveViewSettingCategory) {
        switch category {
        case .saveStart, .saveStop:
            let isOn = category == .saveStart
            if !isOn {
                UserDefaultService.searchWordSave(keywordList: [])
                nowSaveWords.accept([SearchKeywordSection(items: [], isEdit: false)])
            }
            
            UserDefaultService.isAutoSaveValueSet(on: isOn)
            nowKeywordAutoSave.accept(isOn)
            
        case .wordAllRemove:
            nowSaveWords.accept([SearchKeywordSection(items: [], isEdit: false)])
            UserDefaultService.searchWordSave(keywordList: [])
            
        case .wordRemove:
            let data = [SearchKeywordSection(items: nowSaveWords.value.first!.items, isEdit: true)]
            nowSaveWords.accept(data)
        }
        
        switch category {
        case .saveStart, .wordAllRemove, .wordRemove:
            nowCellErrorMSG.execute(.notContents)
            
        case .saveStop:
            nowCellErrorMSG.execute(.searchWordSaveOff)
        }
    }
    
    private func bookLoad() {
        let nowSearchKeyword = nowSearchKeyword.value
        BookListLoad.bookListSearch(query: nowSearchKeyword.0, nextPage: "\(nowSearchKeyword.1)")
            .subscribe(onSuccess: { [weak self] data in
                if data.books.isEmpty {
                    self?.nowSearchErrorMSG.execute(.error_800)
                    self?.nowSearchData.accept([])
                } else if data.page == "1" {
                    self?.nowSearchData.accept(data.books)
                } else {
                    var list = self?.nowSearchData.value
                    
                    list?.append(contentsOf: data.books)
                    self?.nowSearchData.accept(list ?? [])
                }
            }, onFailure: { [weak self] error in
                guard let urlError = error as? NetworkingError else {
                    self?.nowSearchErrorMSG.execute(.error_499)
                    return
                }
                
                switch urlError {
                case .error_999:
                    self?.nowSearchErrorMSG.execute(urlError)
                    
                default:
                    self?.nowSearchErrorMSG.execute(.error_499)
                }
            })
            .disposed(by: rx.disposeBag)
    }
    
    override init(
        
    ) {
        
    }
}
