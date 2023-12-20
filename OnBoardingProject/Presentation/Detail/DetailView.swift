//
//  DetailView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import UIKit
import Kingfisher
import Then
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx

class DetailView: UIView {
    fileprivate lazy var loadingView: DetailLoadingView? = DetailLoadingView()
    
    private lazy var backGroundView = UIView().then {
        $0.backgroundColor = .systemGray4
    }
    
    fileprivate lazy var bookImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    fileprivate lazy var infoView = StandardInfoView()
    
    private lazy var borderView = UIView().then {
        $0.backgroundColor = .systemGray4
    }
    
    lazy var memoInput = UITextView().then {
        $0.textColor = .systemGray4
        $0.text = DefaultMSG.Detail.memoPlaceHolder
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray4.cgColor
        $0.layer.cornerRadius = 16
    }
    
    typealias Model = BookData
    private let actionRelay = PublishRelay<DetailViewActionType>()
    var modelData: Model?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bind() {
        infoView.urlTitle.rx.tap
            .withUnretained(self)
            .map {
                .browserIconTap(book: $0.0.modelData)
            }
            .bind(to: actionRelay)
            .disposed(by: rx.disposeBag)
        
        memoInput.rx.didBeginEditing
            .withLatestFrom(memoInput.rx.text)
            .bind(to: rx.placeHolderOff)
            .disposed(by: rx.disposeBag)
        
        memoInput.rx.didEndEditing
            .bind(to: rx.placeHolderOn)
            .disposed(by: rx.disposeBag)
    }
    
    @discardableResult
    func setupDI(relay: PublishRelay<DetailViewActionType>) -> Self {
        actionRelay
            .bind(to: relay)
            .disposed(by: rx.disposeBag)
        
        return self
    }
    
    @discardableResult
    func setupDI(observable: Observable<Model>) -> Self {
        let filterData = observable
            .filter {$0.bookID != DefaultMSG.Detail.loading}
        
        filterData
            .map {_ in Void()}
            .bind(to: rx.loadingEnd)
            .disposed(by: rx.disposeBag)
        
        filterData
            .bind(to: rx.viewDataSet)
            .disposed(by: rx.disposeBag)
        
        filterData
            .withUnretained(self)
            .subscribe(onNext: { view, data in
                view.modelData = data
            })
            .disposed(by: rx.disposeBag)
        
        return self
    }
    
    @discardableResult
    func setupDI(memoData: Observable<String>) -> Self {
        memoData
            .bind(to: rx.memoSet)
            .disposed(by: rx.disposeBag)
      
        return self
    }
    
    private func layout() {
        addSubviews([backGroundView, borderView, memoInput, infoView])
        
        backGroundView.snp.makeConstraints {
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.top.equalTo(safeAreaLayoutGuide).inset(12)
            $0.height.equalTo(220)
        }
        
        backGroundView.addSubview(bookImageView)
        bookImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(160)
            $0.height.equalTo(200)
        }
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(backGroundView.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(12)
        }
        
        borderView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalTo(infoView).inset(6)
            $0.height.equalTo(1)
            $0.top.equalTo(infoView.snp.bottom).offset(6)
        }
        
        memoInput.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide).inset(12)
            $0.top.equalTo(borderView.snp.bottom).offset(18)
        }
        
        guard let loadingView = self.loadingView else {return}
        
        addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview().inset(12)
        }
    }
}

extension Reactive where Base: DetailView {
    var placeHolderOff: Binder<String?> {
        return Binder(base) { base, text in
            if text == DefaultMSG.Detail.memoPlaceHolder {
                base.memoInput.text = nil
                base.memoInput.textColor = .label
            }
        }
    }
    
    var placeHolderOn: Binder<Void> {
        return Binder(base) { base, _ in
            if base.memoInput.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                base.memoInput.text = DefaultMSG.Detail.memoPlaceHolder
                base.memoInput.textColor = .systemGray4
            }
        }
    }
    
    var viewDataSet: Binder<BookData> {
        return Binder(base) { base, data in
            base.infoView.infoViewDataSet(data)
            
            if data.urlString != DefaultMSG.Detail.loading {
                base.bookImageView.kf.setImage(with: data.imageURL)
            }
        }
    }
    
    var memoSet: Binder<String> {
        return Binder(base) { base, memoContents in
            if memoContents != "" {
                base.memoInput.text = memoContents
                base.memoInput.textColor = .label
            }
        }
    }
    
    var loadingEnd: Binder<Void> {
        return Binder(base) { base, _ in
            UIView.animate(
                withDuration: 0.2,
                animations: {
                    base.loadingView?.alpha = 0
                }, completion: { _ in
                    base.loadingView?.removeFromSuperview()
                    base.loadingView = nil
                }
            )
        }
    }
}
