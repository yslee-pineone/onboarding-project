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
                return cell
            }
            .disposed(by: bag)
        
        output.cellData
            .map {_ in}
            .drive(rx.refreshEnd)
            .disposed(by: bag)
        
        tableView.rx.modelSelected(BookData.self)
            .map {$0.bookID}
            .subscribe(rx.detailVCPush)
            .disposed(by: bag)
    }
}

extension Reactive where Base: MainViewController {
    var refreshEnd: Binder<Void> {
        return Binder(base) { base, _ in
            base.tableView.refresh.endRefreshing()
        }
    }
    
    var detailVCPush: Binder<String> {
        return Binder(base) { base, id in
            let viewModel = DetailViewModel(id: id)
            let vc = DetailViewController(viewModel: viewModel)
            vc.hidesBottomBarWhenPushed = true
            
            base.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
