//
//  SearchBarViewController.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import NSObject_Rx

class SearchBarViewController: UISearchController {
    
    // MARK: - Properties
    
    typealias Model = [BookData]
    
    let actionRelay = PublishRelay<SearchViewActionType>()
    
    // MARK: - Lifecycle
    
    override init(searchResultsController: UIViewController?) {
        super.init(searchResultsController: searchResultsController)
        attribute()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func attribute() {
        searchBar.placeholder = DefaultMSG.Search.searchStart
    }
    
    private func bind() {
        searchBar.rx.text
            .filter {$0 != nil}
            .map {.searchText(text: $0!)}
            .debounce(.milliseconds(500), scheduler: MainScheduler.asyncInstance)
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
        
        searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
            .map {_ in .enterTap}
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
    }
    
    @discardableResult
    func setupDI(relay: PublishRelay<SearchViewActionType>) -> Self {
        actionRelay
            .bind(to: relay)
            .disposed(by: rx.disposeBag)
        
        return self
    }
    
    @discardableResult
    func setupDI(saveKeywordTap: Observable<String>) -> Self{
        saveKeywordTap
            .bind(to: rx.searchPresent)
            .disposed(by: rx.disposeBag)
        
        return self
    }
}

// MARK: - ReactiveSearchBarViewController

extension Reactive where Base: SearchBarViewController {
    var searchPresent: Binder<String>{
        return Binder(base){base, data in
            base.searchBar.text = data
            base.isActive = true
        }
    }
}
