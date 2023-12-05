//
//  MainVC.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

import RxSwift
import RxCocoa
import Then
import SnapKit

class MainVC: UIViewController {
    var refresh = UIRefreshControl().then {
        $0.tintColor = .label
    }
    
    let tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.rowHeight = UITableView.automaticDimension
        $0.register(MainTableViewCell.self, forCellReuseIdentifier: MainTableViewCell.id)
        $0.backgroundColor = .systemBackground
    }
    
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
        self.attribute()
        self.layout()
        self.bind()
    }
}

private extension MainVC {
    func attribute() {
        self.view.backgroundColor = .systemBackground
        self.tableView.refreshControl = self.refresh
        self.navigationItem.title = "New Books"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func layout() {
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func bind() {
        let input = MainViewModel.Input(
            refreshEvent: self.refresh.rx.controlEvent(.valueChanged)
                .startWith(Void())
                .asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        output.cellData
            .drive(self.tableView.rx.items) { tableView, row, data in
                guard let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.id, for: IndexPath(row: row, section: 0)) as? MainTableViewCell else {return UITableViewCell()}
                
                cell.cellDataSet(data: data)
                return cell
            }
            .disposed(by: self.bag)
    }
}
