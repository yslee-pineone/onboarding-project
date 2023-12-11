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
    let viewModel: WebViewModel
    
    lazy var webView = WebView().then {
        $0.navigationDelegate = self
        $0.uiDelegate = self
    }
    
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
        let input = WebViewModel.Input()
        let output = viewModel.transform(input: input)
        
        output.loadingURL
            .filter {$0 != nil}
            .map {$0!}
            .drive(rx.webViewLoad)
            .disposed(by: rx.disposeBag)
        
        output.loadingURL
            .filter {$0 == nil}
            .withLatestFrom(output.title)
            .drive(rx.webViewURLErrorPopup)
            .disposed(by: rx.disposeBag)
        
        output.title
            .drive(rx.viewControllerTitleSet)
            .disposed(by: rx.disposeBag)
    }
}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.webView.loadingIcon.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.webView.loadingIcon.stopAnimating()
    }
}

extension WebViewController: WKUIDelegate {
    func webView(
        _ webView: WKWebView,
        runJavaScriptAlertPanelWithMessage message: String,
        initiatedByFrame frame: WKFrameInfo,
        completionHandler: @escaping () -> Void
    ) {
        
        let alertController = UIAlertController()
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
        
        let alertController = UIAlertController()
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
    var webViewLoad: Binder<URL> {
        return Binder(base) { base, url in
            let request = URLRequest(url: url)
            base.webView.load(request)
        }
    }
    
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
