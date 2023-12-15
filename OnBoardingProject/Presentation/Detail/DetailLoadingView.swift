//
//  DetailLoadingView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import UIKit
import Then
import SnapKit

class DetailLoadingView: UIView {
    private lazy var loadingIcon = UIActivityIndicatorView(style: .medium).then {
        $0.color = .white
    }
    
    private lazy var loadingTitle = UILabel().then {
        $0.textColor = .white
        $0.font = .systemFont(ofSize: FontStyle.mid, weight: .bold)
        $0.text = DefaultMSG.Detail.loading
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
        attrubute()
        loadingIcon.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attrubute() {
        backgroundColor = .gray.withAlphaComponent(0.5)
    }
    
    private func layout() {
        addSubviews([loadingIcon, loadingTitle])
        
        loadingIcon.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-24)
        }
        
        loadingTitle.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
