//
//  WebView.swift
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

class WebView: WKWebView {
    private lazy var loadingIcon = UIActivityIndicatorView(style: .medium).then {
        $0.color = .label
    }
    
    private let actionRelay = PublishRelay<WebViewActionType>()
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.layout()
        navigationDelegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(loadingIcon)
        loadingIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-24)
        }
    }
    
    @discardableResult
    func setupDI(relay: PublishRelay<WebViewActionType>) -> Self {
        actionRelay
            .bind(to: relay)
            .disposed(by: rx.disposeBag)
        return self
    }
    
    @discardableResult
    func setupDI(url: Observable<URL?>) -> Self {
        url
            .filter {$0 != nil}
            .map {$0!}
            .bind(to: rx.webViewLoad)
            .disposed(by: rx.disposeBag)
        return self
    }
}

extension WebView: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingIcon.startAnimating()
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingIcon.stopAnimating()
    }
}

extension Reactive where Base: WebView {
    var webViewLoad: Binder<URL> {
        return Binder(base) { base, url in
            let request = URLRequest(url: url)
            base.load(request)
        }
    }
}
