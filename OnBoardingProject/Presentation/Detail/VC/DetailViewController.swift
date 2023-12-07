//
//  DetailViewController.swift
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

class DetailViewController: UIViewController {
    let viewModel: DetailViewModel
    let didDisappear = PublishSubject<String>()
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
    
    lazy var memoInput = UITextView().then {
        $0.textColor = .systemGray4
        $0.text = DefaultMSG.Detail.memoPlaceHolder.rawValue
        $0.delegate = self
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
    
    deinit {
        print("DEINIT DETAILVC")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attribute()
        self.toolBarSet()
        self.layout()
        self.bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.memoInput.resignFirstResponder()
        self.didDisappear.onNext(self.memoInput.text)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func attribute() {
        self.view.backgroundColor = .systemBackground
        self.navigationItem.title = DefaultMSG.Detail.title.rawValue
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func toolBarSet() {
        let doneItem = UIBarButtonItem(
            title: DefaultMSG.Detail.keyboardDonBtn.rawValue,
            style: .done,
            target: self,
            action: #selector(self.keyboardToolBarDoneBtnTap(_:))
        )
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let keyboardTool = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        keyboardTool.sizeToFit()
        keyboardTool.setItems([space, doneItem], animated: true)
        
        self.memoInput.inputAccessoryView = keyboardTool
    }
    
    private func layout() {
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
            $0.width.equalTo(160)
            $0.height.equalTo(200)
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
    
    private func bind() {
        let input = DetailViewModel.Input(
            didDisappearMemoContents: self.didDisappear
                .asObservable()
        )
        
        let output = self.viewModel.transform(input: input)
        output.bookData
            .drive(self.rx.viewDataSet)
            .disposed(by: self.bag)
        
        output.memoData
            .filter {$0 != DefaultMSG.Detail.memoPlaceHolder.rawValue}
            .drive(self.rx.memoSet)
            .disposed(by: self.bag)
    }
    
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height - 15
        
        self.memoInput.snp.remakeConstraints {
            $0.top.equalTo(self.view.safeAreaLayoutGuide).inset(PaddingStyle.standard.ofSize)
            $0.leading.trailing.equalTo(self.view.safeAreaLayoutGuide)
            $0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(keyboardHeight)
        }
        
        UIView.animate(withDuration: 0.25){
            self.view.layoutIfNeeded()
            self.infoView.alpha = 0
            self.borderView.alpha = 0
        }
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        self.memoInput.snp.remakeConstraints {
            $0.leading.trailing.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(PaddingStyle.standard.ofSize)
            $0.top.equalTo(self.borderView.snp.bottom).offset(PaddingStyle.standardPlus.ofSize)
        }
        UIView.animate(withDuration: 0.25){
            self.view.layoutIfNeeded()
            self.infoView.alpha = 1
            self.borderView.alpha = 1
        }
    }
    
    @objc
    private func keyboardToolBarDoneBtnTap(_ sender: Any) {
        self.memoInput.resignFirstResponder()
    }
}

extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == DefaultMSG.Detail.memoPlaceHolder.rawValue {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = DefaultMSG.Detail.memoPlaceHolder.rawValue
            textView.textColor = .systemGray4
        }
    }
}

extension Reactive where Base: DetailViewController {
    var viewDataSet: Binder<BookData> {
        return Binder(base) { base, data in
            base.infoView.infoViewDataSet(data)
            
            if data.urlString != DefaultMSG.Detail.loading.rawValue {
                base.bookImageView.kf.setImage(with: data.imageURL)
            }
        }
    }
    
    var memoSet: Binder<String> {
        return Binder(base) { base, memoContents in
            if memoContents != "" {
                base.memoInput.text = memoContents
                base.memoInput.textColor = .black
            }
        }
    }
}
