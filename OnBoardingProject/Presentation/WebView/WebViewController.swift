//
//  WebViewController.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/11/23.
//

import UIKit
import WebKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import NSObject_Rx

class WebViewController: UIViewController {
    fileprivate lazy var webView = WebView().then {
        $0.uiDelegate = self
    }
    
    private let viewModel: WebViewModel
    private let actionRelay = PublishRelay<WebViewActionType>()
    
    init(
        viewModel: WebViewModel
    ) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("DEINIT WEBVIEWVC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        attribute()
        bind()
    }
    
    private func attribute() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
    }
    
    private func layout() {
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }
    }
    
    private func bind() {
        let input = WebViewModel.Input(
            actionTrigger: actionRelay
            .asObservable()
        )
        let output = viewModel.transform(input: input)
        
        webView
            .setupDI(relay: actionRelay)
            .setupDI(url: output.loadingURL)
        
        output.loadingURL
            .filter {$0 == nil}
            .withLatestFrom(output.title)
            .bind(to: rx.webViewURLErrorPopup)
            .disposed(by: rx.disposeBag)
        
        output.title
            .bind(to: rx.viewControllerTitleSet)
            .disposed(by: rx.disposeBag)
    }
}

extension WebViewController: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(
                title: "확인",
                style: .default,
                handler: { _ in
                    completionHandler()
                }
            )
        )
        
        present(alertController, animated: true)
    }
    
    func webView(
        _ webView: WKWebView,
        runJavaScriptConfirmPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping (Bool) -> Void
    ) {
        
        let alertController = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        alertController.addAction(
            UIAlertAction(
                title: "확인",
                style: .default,
                handler: { _ in
                    completionHandler(true)
                }
            )
        )
        
        alertController.addAction(
            UIAlertAction(
                title: "취소",
                style: .cancel,
                handler: { _ in
                    completionHandler(false)
                }
            )
        )
        
        present(alertController, animated: true)
    }
}


extension Reactive where Base: WebViewController {
    var viewControllerTitleSet: Binder<String> {
        return Binder(base) { base, title in
            base.title = title
        }
    }
    
    var webViewURLErrorPopup: Binder<String> {
        return Binder(base) { base, title in
            let alert = UIAlertController(
                title: DefaultMSG.WebView.urlErrorTitle,
                message: DefaultMSG.WebView.urlErrorContents(title: title),
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(
                title: "닫기",
                style: .cancel,
                handler: { _ in
                    base.navigationController?.popViewController(animated: true)
                }
            ))
            base.present(alert, animated: true)
        }
    }
}
