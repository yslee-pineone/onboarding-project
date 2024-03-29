//
//  DetailViewController.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx

class DetailViewController: UIViewController, ViewModelProtocol {
    typealias ViewModel = DetailViewModel
    
    // MARK: - ViewModelProtocol
    
    var viewModel: ViewModel!
    
    // MARK: - Properties
    
    private lazy var scrollView = UIScrollView()
    fileprivate lazy var detailView = DetailView()
    
    fileprivate let actionRelay = PublishRelay<DetailViewActionType>()
    
    // MARK: - Lifecycle
    
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
        
        actionRelay
            .accept(.didDisappearMemoContents(memo: detailView.memoInput.text))
        NotificationCenter.default.removeObserver(self)
        detailView.memoInput.resignFirstResponder()
    }
    
    // MARK: - Methods
    
    private func attribute() {
        view.backgroundColor = .systemBackground
        navigationItem.title = DefaultMSG.Detail.title
        navigationController?.navigationBar.prefersLargeTitles = true
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification, object: nil
        )
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
            actionTrigger: actionRelay.asObservable()
        )
        let output = viewModel.transform(input: input)
        
        detailView
            .setupDI(relay: actionRelay)
            .setupDI(observable: output.bookData)
            .setupDI(memoData: output.memoData)
        
        output.errorMSG
            .bind(to: rx.errorPopup)
            .disposed(by: rx.disposeBag)
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
        
        scrollView.scrollRectToVisible(
            CGRectMake(0,
                       scrollView.contentSize.height-self.scrollView.bounds.height,
                       scrollView.bounds.size.width,
                       scrollView.bounds.size.height)
            ,animated: true)
    }
    
    @objc
    private func keyboardWillHide(_ sender: Notification) {
        scrollView.setContentOffset(CGPoint(x: 0, y: -1), animated: true)
        scrollView.sizeToFit()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            let contentInset = UIEdgeInsets.zero
            self.scrollView.contentInset = contentInset
            self.scrollView.scrollIndicatorInsets = contentInset
        }
    }
    
    @objc
    private func keyboardToolBarDoneBtnTap(_ sender: Any) {
        detailView.memoInput.resignFirstResponder()
    }
}

// MARK: - ReactiveDetailViewController

extension Reactive where Base: DetailViewController {
    var errorPopup: Binder<String> {
        return Binder(base) { base, msg in
            let alertController = UIAlertController(title: msg, message: "", preferredStyle: .alert)
            alertController.addAction(
                UIAlertAction(
                    title: "확인",
                    style: .default,
                    handler: { _ in
                        base.actionRelay.accept(.errorPopupOkBtnTap)
                    }
                )
            )
            
            base.present(alertController, animated: true)
        }
    }
}
