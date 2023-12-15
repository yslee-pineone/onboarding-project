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

class WebView: WKWebView {
    lazy var loadingIcon = UIActivityIndicatorView(style: .medium).then {
        $0.color = .label
    }
    
    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        self.layout()
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
}
 
