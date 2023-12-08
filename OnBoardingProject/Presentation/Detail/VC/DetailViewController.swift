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
    lazy var scrollView = UIScrollView()
    lazy var detailView = DetailView()
    
    let viewModel: DetailViewModel
    let didDisappear = PublishSubject<String>()
    let bag = DisposeBag()
    
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
        attribute()
        toolBarSet()
        layout()
        bind()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        detailView.memoInput.resignFirstResponder()
        didDisappear.onNext(detailView.memoInput.text)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func attribute() {
        view.backgroundColor = .systemBackground
        navigationItem.title = DefaultMSG.Detail.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    private func layout() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        scrollView.addSubview(detailView)
        detailView.snp.makeConstraints {
            $0.edges.width.height.equalToSuperview()
        }
    }
    
    private func toolBarSet() {
        let doneItem = UIBarButtonItem(
            title: DefaultMSG.Detail.keyboardDonBtn,
            style: .done,
            target: self,
            action: #selector(keyboardToolBarDoneBtnTap(_:))
        )
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        
        let keyboardTool = UIToolbar(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        keyboardTool.sizeToFit()
        keyboardTool.setItems([space, doneItem], animated: true)
        
        detailView.memoInput.inputAccessoryView = keyboardTool
    }
    
    private func bind() {
        let input = DetailViewModel.Input(
            didDisappearMemoContents: didDisappear
                .asObservable()
        )
        
        let output = viewModel.transform(input: input)
        output.bookData
            .drive(rx.viewDataSet)
            .disposed(by: bag)
        
        output.memoData
            .filter {$0 != DefaultMSG.Detail.memoPlaceHolder}
            .drive(rx.memoSet)
            .disposed(by: bag)
    }
    
    @objc
    private func keyboardWillShow(_ sender: Notification) {
        let userInfo:NSDictionary = sender.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIResponder.keyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height - 15
        
        let contentInset = UIEdgeInsets(
                top: 0,
                left: 0,
                bottom: keyboardHeight,
                right: 0
        )
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        self.scrollView.scrollRectToVisible(
            CGRectMake(0,
                       self.scrollView.contentSize.height-self.scrollView.bounds.height,
                       self.scrollView.bounds.size.width,
                       self.scrollView.bounds.size.height)
            ,animated: true)
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        let contentInset = UIEdgeInsets.zero
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
    }
    
    @objc
    private func keyboardToolBarDoneBtnTap(_ sender: Any) {
        detailView.memoInput.resignFirstResponder()
    }
}

extension DetailViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == DefaultMSG.Detail.memoPlaceHolder {
            textView.text = nil
            textView.textColor = .black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            textView.text = DefaultMSG.Detail.memoPlaceHolder
            textView.textColor = .systemGray4
        }
    }
}

extension Reactive where Base: DetailViewController {
    var viewDataSet: Binder<BookData> {
        return Binder(base) { base, data in
            base.detailView.infoView.infoViewDataSet(data)
            
            if data.urlString != DefaultMSG.Detail.loading {
                base.detailView.bookImageView.kf.setImage(with: data.imageURL)
            }
        }
    }
    
    var memoSet: Binder<String> {
        return Binder(base) { base, memoContents in
            if memoContents != "" {
                base.detailView.memoInput.text = memoContents
                base.detailView.memoInput.textColor = .black
            }
        }
    }
}
