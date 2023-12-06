//
//  DetailVC.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit

import Kingfisher
import Then
import SnapKit
import RxSwift
import RxCocoa

class DetailVC: UIViewController {
    let viewModel: DetailViewModel
    let didDisappear = PublishSubject<Void>()
    let bag = DisposeBag()
    
    let backGroundView = UIView().then {
        $0.backgroundColor = .systemGray4
    }
    
    let bookImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    let infoView = StandardInfoView()
    
    let borderView = UIView().then {
        $0.backgroundColor = .systemGray4
    }
    
    let memoInput = UITextView().then {
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor.systemGray4.cgColor
        $0.layer.cornerRadius = 16
    }
    
    init(
        viewModel: DetailViewModel
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
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.didDisappear.onNext(Void())
    }
}

private extension DetailVC {
    func attribute() {
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = "Detail Book"
        self.navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func layout() {
        [self.backGroundView, self.borderView, self.memoInput, self.infoView]
            .forEach {
                self.view.addSubview($0)
            }
        
        self.backGroundView.snp.makeConstraints {
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(PaddingStyle.standard.ofSize)
            $0.height.equalTo(220)
        }
        
        self.backGroundView.addSubview(self.bookImageView)
        self.bookImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(160)
        }
        
         self.infoView.snp.makeConstraints {
             $0.top.equalTo(self.backGroundView.snp.bottom).offset(PaddingStyle.standardHalf.ofSize)
             $0.leading.trailing.equalToSuperview().inset(PaddingStyle.standard.ofSize)
         }
        
        self.borderView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalTo(self.infoView).inset(PaddingStyle.standardHalf.ofSize)
            $0.height.equalTo(1)
            $0.top.equalTo(self.infoView.snp.bottom).offset(PaddingStyle.standardHalf.ofSize)
        }
        
        self.memoInput.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(PaddingStyle.standard.ofSize)
            $0.top.equalTo(self.borderView.snp.bottom).offset(PaddingStyle.standardPlus.ofSize)
        }
    }
    
    func bind() {
        let input = DetailViewModel.Input(
            viewDidDisappear: self.didDisappear
                .asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        output.bookData
            .drive(self.rx.viewDataSet)
            .disposed(by: self.bag)
    }
}

extension Reactive where Base: DetailVC {
    var viewDataSet: Binder<BookData> {
        return Binder(base) { base, data in
            base.infoView.infoViewDataSet(data)
            base.bookImageView.kf.setImage(with: data.imageURL)
        }
    }
}
