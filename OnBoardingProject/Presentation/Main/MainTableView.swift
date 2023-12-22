//
//  MainTableView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx

class MainTableView: UITableView {
    typealias Model = [BookData]
    
    // MARK: - Properties
    
    fileprivate lazy var refresh = UIRefreshControl().then {
        $0.tintColor = .label
    }
    
    fileprivate lazy var noSearchListLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.isHidden = true
        $0.font = UIFont.systemFont(ofSize: FontStyle.mid, weight: .semibold)
        $0.text = DefaultMSG.Main.empty
    }
    
    private let actionRelay = PublishRelay<MainViewActionType>()
    
    // MARK: - init
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        attribute()
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Method
    
    private func attribute() {
        dataSource = nil
        delegate = nil
        
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        register(cellType: StandardTableViewCell.self)
        backgroundColor = .systemBackground
        refreshControl = refresh
    }
    
    private func layout() {
        addSubview(noSearchListLabel)
        noSearchListLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(24)
        }
    }
    
    private func bind() {
        rx.modelSelected(BookData.self)
            .map {.cellTap(bookID: $0.bookID)}
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
        
        refresh.rx.controlEvent(.valueChanged)
            .startWith(())
            .delay(.microseconds(500), scheduler: MainScheduler.asyncInstance)
            .map {.refreshEvent}
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
    }
    
    @discardableResult
    func setupDI(relay: PublishRelay<MainViewActionType>) -> Self {
        actionRelay
            .bind(to: relay)
            .disposed(by: rx.disposeBag)
        
        return self
    }
    
    @discardableResult
    func setupDI(observable: Observable<Model>) -> Self {
        observable
            .bind(to: rx.items(
                cellIdentifier: StandardTableViewCell.reuseIdentifier,
                cellType: StandardTableViewCell.self
            )) { [weak self] row, data, cell in
                cell.cellDataSet(data: data)
                
                guard let self = self else {return}
                
                cell.browserIcon.rx.tap
                    .withLatestFrom(
                        Observable<BookData>
                            .just(data)
                    )
                    .map {.browserIconTap(book: $0)}
                    .bind(to: self.actionRelay)
                    .disposed(by: cell.bag)
            }
            .disposed(by: rx.disposeBag)
        
        observable
            .map {_ in}
            .bind(to: rx.refreshEnd)
            .disposed(by: rx.disposeBag)
        
        observable
            .map {_ in true}
            .bind(to: noSearchListLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        return self
    }
    
    @discardableResult
    func setupDI(errorMSG: Observable<String>) -> Self {
        errorMSG
            .bind(to: noSearchListLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        errorMSG
            .map {_ in false}
            .bind(to: noSearchListLabel.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        errorMSG
            .map {_ in}
            .bind(to: rx.refreshEnd)
            .disposed(by: rx.disposeBag)
        
        return self
    }
}

// MARK: - ReactiveMainTableView

extension Reactive where Base: MainTableView {
    var refreshEnd: Binder<Void> {
        return Binder(base) { base, _ in
            base.refresh.endRefreshing()
        }
    }
}
