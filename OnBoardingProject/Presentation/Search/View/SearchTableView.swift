//
//  SearchTableView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/15/23.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import NSObject_Rx

class SearchTableView: UITableView {
     lazy var searchWordSaveView = SearchWordSaveView(
        frame: CGRect(x: 0, y: 0, width: frame.size.width, height: 80)
    )
    
    typealias Model = [BookData]
    let actionRelay = PublishRelay<SearchViewActionType>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        attribute()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        register(cellType: StandardTableViewCell.self)
        backgroundColor = .systemBackground
        
        tableHeaderView = searchWordSaveView
    }
    
    private func bind() {
        rx.modelSelected(BookData.self)
            .map {.cellTap(bookID: $0.bookID)}
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
        
        searchWordSaveView.collectionView.rx.modelSelected(String.self)
            .withLatestFrom(searchWordSaveView.collectionView.rx.itemSelected) {($0,$1.row)}
            .map {.saveCellTap(word: $0.0, row: $0.1)}
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
        
        searchWordSaveView.doneBtn.rx.tap
            .map {.editModeDone}
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
        
        searchWordSaveView.doneBtn.rx.tap
            .bind(to: rx.editModeOff)
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
            .filter {!$0.isEmpty}
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
        
        return self
    }
    
    @discardableResult
    func setupDI<T>(observable: Observable<T>) -> Self {
        if let observable = observable as? Observable<[SearchKeywordSection]> {
            let dataSources = RxCollectionViewSectionedReloadDataSource<SearchKeywordSection>(
                configureCell: { dataSources, collectionView, index, data in
                    guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: SearchWordSaveViewCell.reuseIdentifier,
                        for: index
                    ) as? SearchWordSaveViewCell else {return UICollectionViewCell()}
                    
                    cell.cellSet(title: data, isEdit: dataSources.sectionModels.first?.isEdit ?? false)
                    return cell
                })
            
            observable
                .bind(to: searchWordSaveView.collectionView.rx.items(dataSource: dataSources))
                .disposed(by: rx.disposeBag)
            
            observable
                .map {!$0.first!.items.isEmpty}
                .bind(to: searchWordSaveView.titleLabel.rx.isHidden)
                .disposed(by: rx.disposeBag)
            
        } else if let msgObservable = observable as? Observable<String> {
            msgObservable
                .bind(to: searchWordSaveView.titleLabel.rx.text)
                .disposed(by: rx.disposeBag)
        }
        
        return self
    }
}

extension Reactive where Base: SearchTableView {
    var editModeOff: Binder<Void>{
        return Binder(base){base, _ in
            base.searchWordSaveView.editMode(isOn: false)
        }
    }
}
