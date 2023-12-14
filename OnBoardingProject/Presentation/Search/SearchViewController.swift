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
    fileprivate lazy var searchWordSaveView = SearchWordSaveView(
        frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 80)
    )
    
    fileprivate lazy var tableView = UITableView().then {
        $0.tableHeaderView = searchWordSaveView
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.register(StandardTableViewCell.self, forCellReuseIdentifier: StandardTableViewCell.id)
        $0.backgroundColor = .systemBackground
    }
    
    fileprivate var searchBarViewController: SearchBarViewController!
    private let searchResultViewController: SearchResultViewController
    
    private let viewModel: SearchViewModel
    fileprivate let settingPopupTap = PublishSubject<SearchWordSaveViewSettingCategory>()
    
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
        let cellBrowerIconTap = PublishSubject<BookData>()
        
        let bookListTap = Observable.merge(
            searchResultViewController.tableView.rx.modelSelected(BookData.self)
                .asObservable(),
            tableView.rx.modelSelected(BookData.self)
                .asObservable()
        )
        
        bookListTap
            .map {$0.bookID}
            .bind(to: rx.detailVCPush)
            .disposed(by: rx.disposeBag)
        
        cellBrowerIconTap
            .bind(to: rx.webViewControllerPush)
            .disposed(by: rx.disposeBag)
        
        searchWordSaveView.doneBtn.rx.tap
            .bind(to: rx.editModeOff)
            .disposed(by: rx.disposeBag)
        
        let input = SearchViewModel.Input(
            searchText: searchBarViewController.searchBar.rx.text
                .filter {$0 != nil}
                .map {$0!},
            nextDisplayIndex: searchResultViewController.tableView.rx.willDisplayCell
                .map {$0.indexPath},
            enterTap: searchBarViewController.searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
                .map {_ in Void()},
            saveCellTap: searchWordSaveView.collectionView.rx.modelSelected(String.self)
                .withLatestFrom(searchWordSaveView.collectionView.rx.itemSelected) {($0,$1.row)}
                .asObservable(),
            settingMenuTap: settingPopupTap
                .asObservable(),
            editModeDoneTap: searchWordSaveView.doneBtn.rx.tap
                .asObservable()
        )
        
        let output = viewModel.transform(input: input)
        output.cellData
            .bind(to: searchResultViewController.tableView.rx.items) { tableView, row, data in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchResultTableViewCell.id,
                    for: IndexPath(row: row, section: 0)) as? SearchResultTableViewCell
                else {return UITableViewCell()}
                
                cell.cellDataSet(data: data)
                
                cell.infoView.urlTitle.rx.tap
                    .withLatestFrom(
                        Observable<BookData>
                            .just(data)
                    )
                    .bind(to: cellBrowerIconTap)
                    .disposed(by: cell.bag)
                
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        output.cellData
            .map {!$0.isEmpty}
            .bind(to: searchResultViewController.noSearchListLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        output.cellData
            .filter {!$0.isEmpty}
            .bind(to: tableView.rx.items) { tableView, row, data in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: StandardTableViewCell.id,
                    for: IndexPath(row: row, section: 0)) as? StandardTableViewCell
                else {return UITableViewCell()}
                
                cell.cellDataSet(data: data)
                
                cell.browserIcon.rx.tap
                    .withLatestFrom(
                        Observable<BookData>
                            .just(data)
                    )
                    .bind(to: cellBrowerIconTap)
                    .disposed(by: cell.bag)
                
                return cell
            }
            .disposed(by: rx.disposeBag)
        
        let dataSources = RxCollectionViewSectionedReloadDataSource<SearchKeywordSection>(
            configureCell: { dataSources, collectionView, index, data in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchWordSaveViewCell.id,
                    for: index
                ) as? SearchWordSaveViewCell else {return UICollectionViewCell()}
                
                cell.cellSet(title: data, isEdit: dataSources.sectionModels.first?.isEdit ?? false)
                return cell
            })
        
        output.saveCellData
            .bind(to: searchWordSaveView.collectionView.rx.items(dataSource: dataSources))
            .disposed(by: rx.disposeBag)
        
        output.saveCellData
            .map {!$0.first!.items.isEmpty}
            .bind(to: searchWordSaveView.titleLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        output.saveCellErrorMSG
            .bind(to: searchWordSaveView.titleLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        searchWordSaveView.editBtn.rx.tap
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
        
        searchWordSaveView.collectionView.rx.modelSelected(String.self)
            .catchAndReturn("")
            .withLatestFrom(output.saveCellData) { keyword, data -> String? in
                if data.first!.isEdit {
                    return nil
                } else {
                    return keyword
                }
            }
            .filter {$0 != nil}
            .map {$0!}
            .bind(to: rx.searchPresent)
            .disposed(by: rx.disposeBag)
    }
}

extension Reactive where Base: SearchViewController {
    var detailVCPush: Binder<String> {
        return Binder(base) { base, id in
            let viewModel = DetailViewModel(id: id)
            let vc = DetailViewController(viewModel: viewModel)
            vc.hidesBottomBarWhenPushed = true
            
            base.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    var webViewControllerPush: Binder<BookData> {
        return Binder(base) { base, data in
            let viewModel = WebViewModel(
                title: data.mainTitle,
                bookURL: data.bookURL
            )
            let webViewController = WebViewController(viewModel: viewModel)
            
            webViewController.hidesBottomBarWhenPushed = true
            
            base.navigationController?.pushViewController(
                webViewController,
                animated: true
            )
        }
    }
    
    var searchPresent: Binder<String>{
        return Binder(base){base, data in
            base.searchBarViewController.searchBar.text = data
            base.searchBarViewController.isActive = true
        }
    }
    
    var editModeOff: Binder<Void>{
        return Binder(base){base, _ in
            base.searchWordSaveView.editMode(isOn: false)
        }
    }
    
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
                            base.settingPopupTap.onNext(.wordAllRemove)
                        }))
                
                alert.addAction(
                    UIAlertAction(
                        title: DefaultMSG.Search.Menu.remove,
                        style: .default,
                        handler: { _ in
                            base.searchWordSaveView.editMode(isOn: true)
                            base.settingPopupTap.onNext(.wordRemove)
                        }))
            }
            
            if setting.1 {
                alert.addAction(
                    UIAlertAction(
                        title: DefaultMSG.Search.Menu.notSave,
                        style: .default,
                        handler: { _ in
                            base.settingPopupTap.onNext(.saveStop)
                        }))
            } else {
                alert.addAction(
                    UIAlertAction(
                        title: DefaultMSG.Search.Menu.okSave,
                        style: .default,
                        handler: { _ in
                            base.settingPopupTap.onNext(.saveStart)
                        }))
            }
            
            alert.addAction(UIAlertAction(title: "취소", style: .cancel))
            
            base.present(alert, animated: true)
        }
    }
}
