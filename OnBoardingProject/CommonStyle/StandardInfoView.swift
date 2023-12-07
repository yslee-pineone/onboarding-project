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
    lazy var stackView = UIStackView().then {
        $0.layer.cornerRadius = 16
        $0.spacing = 4
        $0.distribution = .equalCentering
        $0.alignment = .leading
        $0.axis = .vertical
    }
    
    lazy var mainTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.titleBig, weight: .semibold)
    }
    
    lazy var subTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.mid)
    }
    
    lazy var idTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall)
    }
    
    lazy var priceTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall, weight: .semibold)
    }
    
    lazy var urlTitle = UILabel().then {
        $0.textColor = .systemBlue
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        backgroundColor = .clear
    }
    
    private func layout() {
        addSubview(stackView)
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(PaddingStyle.standard)
        }
        
        [mainTitle, subTitle, idTitle, priceTitle, urlTitle]
            .forEach {
                stackView.addArrangedSubview($0)
            }
    }
    
    func infoViewDataSet(_ data: BookData) {
        mainTitle.text = data.mainTitle
        subTitle.text = data.subTitle
        priceTitle.text = data.price
        idTitle.text = data.bookID
        urlTitle.text = data.urlString
    }
}
