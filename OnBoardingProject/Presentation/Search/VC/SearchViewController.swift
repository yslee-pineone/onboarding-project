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

class SearchViewController: UIViewController {
    let viewModel: SearchViewModel
    
    var searchBarViewController: SearchBarViewController!
    let searchResultViewController: SearchResultViewController
    
    lazy var searchWordSaveView = SearchWordSaveView(
        frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 80)
    )
    
    lazy var tableView = UITableView().then {
        $0.tableHeaderView = searchWordSaveView
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.register(StandardTableViewCell.self, forCellReuseIdentifier: StandardTableViewCell.id)
        $0.backgroundColor = .systemBackground
    }
    
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
        
        let input = SearchViewModel.Input(
            searchText: searchBarViewController.searchBar.rx.text
                .filter {$0 != nil}
                .map {$0!},
            nextDisplayIndex: searchResultViewController.tableView.rx.willDisplayCell
                .map {$0.indexPath},
            enterTap: searchBarViewController.searchBar.searchTextField.rx.controlEvent(.editingDidEndOnExit)
                .map {_ in Void()},
            saveCellTap: searchWordSaveView.collectionView.rx.modelSelected(String.self)
                .asObservable()
        )
        
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
        
        searchWordSaveView.collectionView.rx.modelSelected(String.self)
            .bind(to: rx.searchPresent)
            .disposed(by: rx.disposeBag)
        
        let output = viewModel.transform(input: input)
        output.cellData
            .drive(searchResultViewController.tableView.rx.items) { tableView, row, data in
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
            .drive(searchResultViewController.noSearchListLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        output.cellData
            .filter {!$0.isEmpty}
            .drive(tableView.rx.items) { tableView, row, data in
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
        
        output.saveCellData
            .drive(searchWordSaveView.collectionView.rx.items) { collectionView, row, data in
                guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: SearchWordSaveViewCell.id,
                    for: IndexPath(row: row, section: 0)) as? SearchWordSaveViewCell
                else {return UICollectionViewCell()}
                
                cell.titleLabel.text = data
                return cell
            }
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
    
    var searchPresent : Binder<String>{
        return Binder(base){base, data in
            base.searchBarViewController.searchBar.text = data
            base.searchBarViewController.isActive = true
        }
    }
}
