//
//  SearchViewController.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import RxDataSources

class SearchViewController: UIViewController {
    fileprivate let tableView = SearchTableView()
    fileprivate var searchBarViewController: SearchBarViewController!
    private let searchResultViewController: SearchResultViewController
    
    private let viewModel: SearchViewModel
    fileprivate let actionRelay = PublishRelay<SearchViewActionType>()
    
    init(
        viewModel: SearchViewModel,
        searchResultViewController: SearchResultViewController = .init()
    ) {
        self.viewModel = viewModel
        self.searchResultViewController = searchResultViewController
        searchBarViewController = SearchBarViewController(searchResultsController: searchResultViewController)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        attribute()
        layout()
        bind()
    }
    
    private func attribute() {
        view.backgroundColor = .systemBackground
        navigationItem.title = DefaultMSG.Search.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        navigationItem.searchController = searchBarViewController
    }
    
    private func layout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        let input = SearchViewModel.Input(
            actionTrigger: actionRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        tableView
            .setupDI(relay: actionRelay)
            .setupDI(observable: output.saveCellErrorMSG)
            .setupDI(model: output.cellData)
            .setupDI(observable: output.saveCellData)
        
        searchResultViewController
            .setupDI(relay: actionRelay)
            .setupDI(model: output.cellData)
        
        searchBarViewController
            .setupDI(relay: actionRelay)
            .setupDI(saveKeywordTap: output.saveKeywordSearch)
        
        // alert
        tableView.searchWordSaveView.editBtn.rx.tap
            .withLatestFrom(
                Observable.combineLatest (
                    output.saveCellData
                        .map {$0.first!.items}
                        .asObservable(),
                    output.isSearchKeywordSave
                        .asObservable()
                )
            )  
            .bind(to: rx.menuPopup)
            .disposed(by: rx.disposeBag)
    }
}

extension Reactive where Base: SearchViewController {
    var menuPopup: Binder<([String], Bool)> {
        return Binder(base) { base, setting in
            let alert = UIAlertController(
                title: DefaultMSG.Search.Menu.title,
                message: nil,
                preferredStyle: .alert
            )
            
            if !setting.0.isEmpty {
                alert.addAction(
                    UIAlertAction(
                        title: DefaultMSG.Search.Menu.removeAll,
                        style: .default,
                        handler: { _ in
                            base.actionRelay.accept(.settingMenuTap(category: .wordAllRemove))
                        }))
                
                alert.addAction(
                    UIAlertAction(
                        title: DefaultMSG.Search.Menu.remove,
                        style: .default,
                        handler: { _ in
                            base.tableView.searchWordSaveView.editMode(isOn: true)
                            base.actionRelay.accept(.settingMenuTap(category: .wordRemove))
                        }))
            }
            
            if setting.1 {
                alert.addAction(
                    UIAlertAction(
                        title: DefaultMSG.Search.Menu.notSave,
                        style: .default,
                        handler: { _ in
                            base.actionRelay.accept(.settingMenuTap(category: .saveStop))
                        }))
            } else {
                alert.addAction(
                    UIAlertAction(
                        title: DefaultMSG.Search.Menu.okSave,
                        style: .default,
                        handler: { _ in
                            base.actionRelay.accept(.settingMenuTap(category: .saveStart))
                        }))
            }
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            base.present(alert, animated: true)
        }
    }
}
