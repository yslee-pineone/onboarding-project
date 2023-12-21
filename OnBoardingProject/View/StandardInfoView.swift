//
//  StandardInfoView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit
import Then
import SnapKit

class StandardInfoView: UIView {
    
    // MARK: - Propertie
    
    private lazy var stackView = UIStackView().then {
        $0.layer.cornerRadius = 16
        $0.spacing = 4
        $0.distribution = .equalCentering
        $0.alignment = .leading
        $0.axis = .vertical
    }
    
    private lazy var mainTitle = UILabel().then {
        $0.textColor = .label
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.titleBig, weight: .semibold)
    }
    
    private lazy var subTitle = UILabel().then {
        $0.textColor = .label
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.mid)
    }
    
    private lazy var idTitle = UILabel().then {
        $0.textColor = .label
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall)
    }
    
    private lazy var priceTitle = UILabel().then {
        $0.textColor = .label
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall, weight: .semibold)
    }
    
    lazy var urlTitle = UIButton().then {
        $0.setTitleColor(.systemBlue, for: .normal)
        $0.titleLabel?.textAlignment = .center
        $0.titleLabel?.font = .systemFont(ofSize: FontStyle.midSmall)
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func attribute() {
        backgroundColor = .clear
    }
    
    private func layout() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        stackView.addArrangedSubviews([mainTitle, subTitle, idTitle, priceTitle, urlTitle])
    }
    
    func infoViewDataSet(_ data: BookData) {
        mainTitle.text = data.mainTitle
        subTitle.text = data.subTitle
        priceTitle.text = data.price
        idTitle.text = data.bookID
        urlTitle.setTitle(data.urlString, for: .normal)
    }
}
