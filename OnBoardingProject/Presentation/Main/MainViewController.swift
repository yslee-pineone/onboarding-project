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

class MainViewController: UIViewController, ViewModelProtocol {
    typealias ViewModel = MainViewModel
    
    // MARK: - ViewModelProtocol
    
    var viewModel: ViewModel!
    
    // MARK: - Properties
    
    fileprivate lazy var tableView = MainTableView()
    
    private let actionRelay = PublishRelay<MainViewActionType>()
    
    // MARK: - Lifecycle
    
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
    
    // MARK: - Methods
    
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
            actionTrigger: actionRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        tableView
            .setupDI(relay: actionRelay)
            .setupDI(observable: output.cellData)
            .setupDI(errorMSG: output.errorMsg)
    }
}
