//
//  MainViewController.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx

class MainViewController: UIViewController {
    fileprivate lazy var tableView = MainTableView()
    
    private let viewModel: MainViewModel
    
    init(
        viewModel: MainViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
        bind()
    }
    
    private func attribute() {
        view.backgroundColor = .systemBackground
        
        navigationItem.title = DefaultMSG.Main.title
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func layout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func bind() {
        let cellBrowerIconTap = PublishSubject<BookData>()
        
        let input = MainViewModel.Input(
            refreshEvent: tableView.refresh.rx.controlEvent(.valueChanged)
                .startWith(Void())
                .asObservable()
        )
        
        let output = viewModel.transform(input: input)
        output.cellData
            .bind(to: tableView.rx.items) { tableView, row, data in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: StandardTableViewCell.id, 
                    for: IndexPath(row: row, section: 0)
                ) as? StandardTableViewCell else {return UITableViewCell()}
                
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
        
        output.cellData
            .map {_ in}
            .bind(to: rx.refreshEnd)
            .disposed(by: rx.disposeBag)
        
        output.cellData
            .map {!$0.isEmpty}
            .skip(1)
            .bind(to: tableView.noSearchListLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(BookData.self)
            .map {$0.bookID}
            .subscribe(rx.detailViewControllerPush)
            .disposed(by: rx.disposeBag)
            
        cellBrowerIconTap
            .bind(to: rx.webViewControllerPush)
            .disposed(by: rx.disposeBag)
    }
}

extension Reactive where Base: MainViewController {
    var refreshEnd: Binder<Void> {
        return Binder(base) { base, _ in
            base.tableView.refresh.endRefreshing()
        }
    }
    
    var detailViewControllerPush: Binder<String> {
        return Binder(base) { base, id in
            let viewModel = DetailViewModel(id: id)
            let detailViewController = DetailViewController(viewModel: viewModel)
            detailViewController.hidesBottomBarWhenPushed = true
            
            base.navigationController?.pushViewController(
                detailViewController,
                animated: true
            )
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
}
