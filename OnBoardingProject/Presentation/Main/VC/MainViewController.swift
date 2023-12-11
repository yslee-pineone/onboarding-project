//
//  MainViewController.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

import RxSwift
import RxCocoa
import Then
import SnapKit

class MainViewController: UIViewController {
    lazy var tableView = MainTableView()
    
    let viewModel: MainViewModel
    let bag = DisposeBag()
    
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
            .drive(tableView.rx.items) { tableView, row, data in
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
            .disposed(by: bag)
        
        output.cellData
            .map {_ in}
            .drive(rx.refreshEnd)
            .disposed(by: bag)
        
        tableView.rx.modelSelected(BookData.self)
            .map {$0.bookID}
            .subscribe(rx.detailViewControllerPush)
            .disposed(by: bag)
        
        cellBrowerIconTap
            .filter {$0.bookURL == nil}
            .bind(to: rx.webViewURLErrorPopup)
            .disposed(by: bag)
            
        cellBrowerIconTap
            .filter {$0.bookURL != nil}
            .bind(to: rx.webViewControllerPush)
            .disposed(by: bag)
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
                bookURL: data.bookURL!
            )
            let webViewController = WebViewController(viewModel: viewModel)
            
            webViewController.hidesBottomBarWhenPushed = true
            
            base.navigationController?.pushViewController(
                webViewController,
                animated: true
            )
        }
    }
    
    var webViewURLErrorPopup: Binder<BookData> {
        return Binder(base) { base, data in
            let alert = UIAlertController(
                title: DefaultMSG.WebView.urlErrorTitle,
                message: DefaultMSG.WebView.urlErrorContents(title: data.mainTitle),
                preferredStyle: .actionSheet
            )
            alert.addAction(UIAlertAction(
                title: "닫기",
                style: .cancel
            ))
            base.present(alert, animated: true)
        }
    }
}
