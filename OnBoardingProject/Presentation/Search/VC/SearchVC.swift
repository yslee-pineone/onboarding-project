//
//  SearchVC.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit

import RxSwift
import RxCocoa
import Then
import SnapKit

class SearchVC: UIViewController {
    let viewModel: SearchViewModel
    var searchBarVC: SearchBarVC!
    let searchResultVC: SearchResultVC
    
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.id)
        $0.backgroundColor = .systemBackground
    }
    
    let bag = DisposeBag()
    
    init(
        viewModel: SearchViewModel,
        searchResultVC: SearchResultVC = .init()
    ) {
        self.viewModel = viewModel
        self.searchResultVC = searchResultVC
        self.searchBarVC = SearchBarVC(searchResultsController: self.searchResultVC)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.attribute()
        self.layout()
        self.bind()
    }
}

private extension SearchVC {
    func attribute() {
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = DefaultMSG.Search.title.rawValue
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.searchController = self.searchBarVC
    }
    
    func layout() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.edges.equalTo(self.view.safeAreaLayoutGuide)
        }
    }
    
    func bind() {
        let input = SearchViewModel.Input(
            searchText: self.searchBarVC.searchBar.rx.text
                .filter {$0 != nil}
                .map {$0!},
            nextDisplayIndex: self.searchResultVC.tableView.rx.willDisplayCell
                .map {$0.indexPath}
        )
        
        let output = self.viewModel.transform(input: input)
        output.cellData
            .drive(self.searchResultVC.tableView.rx.items) { tableView, row, data in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchResultTableViewCell.id, for: IndexPath(row: row, section: 0)) as? SearchResultTableViewCell
                else {return UITableViewCell()}
                
                cell.cellDataSet(data: data)
                
                return cell
            }
            .disposed(by: self.bag)
        
        output.cellData
            .map {!$0.isEmpty}
            .drive(self.searchResultVC.noSearchListLabel.rx.isHidden)
            .disposed(by: self.bag)
        
        output.cellData
            .filter {!$0.isEmpty}
            .drive(self.tableView.rx.items) { tableView, row, data in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchTableViewCell.id, for: IndexPath(row: row, section: 0)) as? SearchTableViewCell
                else {return UITableViewCell()}
                
                cell.cellDataSet(data: data)
                
                return cell
            }
            .disposed(by: self.bag)
       
        let bookListTap = Observable.merge(
            self.searchResultVC.tableView.rx.modelSelected(BookData.self)
                .asObservable(),
            self.tableView.rx.modelSelected(BookData.self)
                .asObservable()
        )
        
        bookListTap
            .map {$0.bookID}
            .bind(to: self.rx.detailVCPush)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base: SearchVC {
    var detailVCPush: Binder<String> {
        return Binder(base) { base, id in
            let viewModel = DetailViewModel(id: id)
            let vc = DetailVC(viewModel: viewModel)
            vc.hidesBottomBarWhenPushed = true
            
            base.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
