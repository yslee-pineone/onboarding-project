//
//  SearchResultViewController.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then
import NSObject_Rx

class SearchResultViewController: UITableViewController {
    
    // MARK: - Properties
    
    lazy var noSearchListLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.isHidden = true
        $0.font = UIFont.systemFont(ofSize: FontStyle.mid, weight: .semibold)
        $0.text = DefaultMSG.Search.empty
    }
    
    typealias Model = [BookData]
    
    let actionRelay = PublishRelay<SearchViewActionType>()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attirbute()
        layout()
        bind()
    }
    
    // MARK: - Methods
    
    private func attirbute() {
        tableView.register(cellType: SearchResultTableViewCell.self)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .systemBackground
        tableView.delegate = nil
        tableView.dataSource = nil
    }
    
    private func layout() {
        tableView.addSubview(noSearchListLabel)
        noSearchListLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(24)
        }
    }
    
    private func bind() {
        tableView.rx.modelSelected(BookData.self)
            .map {.cellTap(bookID: $0.bookID)}
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.willDisplayCell
            .map {.nextDisplayIndex(index: $0.indexPath)}
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
    func setupDI(model: Observable<Model>) -> Self {
        model
            .bind(to: tableView.rx.items(
                cellIdentifier: SearchResultTableViewCell.reuseIdentifier,
                cellType: SearchResultTableViewCell.self
            )) { [weak self] row, data, cell in
                cell.cellDataSet(data: data)
                
                guard let self = self else {return}
                
                cell.infoView.urlTitle.rx.tap
                    .withLatestFrom(
                        Observable<BookData>
                            .just(data)
                    )
                    .map {.browserIconTap(book: $0)}
                    .bind(to: self.actionRelay)
                    .disposed(by: cell.bag)
            }
            .disposed(by: rx.disposeBag)
        
        model
            .map {!$0.isEmpty}
            .bind(to: noSearchListLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        return self
    }
}
