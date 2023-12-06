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
    
    let bag = DisposeBag()
    
    init(
        viewModel: SearchViewModel,
        searchResultVC: SearchResultVC = .init()
    ) {
        self.viewModel = viewModel
        self.searchResultVC = searchResultVC
        super.init(nibName: nil, bundle: nil)
        
        self.searchBarVC = SearchBarVC(searchResultsController: self.searchResultVC)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        self.attribute()
        self.bind()
    }
}

extension SearchVC {
    private func attribute() {
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Search Books"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.navigationItem.searchController = self.searchBarVC
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
        
        self.searchResultVC.tableView.rx.modelSelected(BookData.self)
            .map {$0.isbn13}
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
