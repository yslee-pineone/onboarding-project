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
    let stackView = UIStackView().then {
        $0.layer.cornerRadius = 16
        $0.spacing = 4
        $0.distribution = .equalCentering
        $0.alignment = .leading
        $0.axis = .vertical
    }
    
    let mainTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.titleBig.ofSize, weight: .semibold)
    }
    
    let subTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.mid.ofSize)
    }
    
    let idTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall.ofSize)
    }
    
    let priceTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall.ofSize, weight: .semibold)
    }
    
    let urlTitle = UILabel().then {
        $0.textColor = .systemBlue
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall.ofSize)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StandardInfoView {
    private func attribute() {
        self.backgroundColor = .clear
    }
    
    private func layout() {
        self.addSubview(self.stackView)
        self.stackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(PaddingStyle.standard.ofSize)
        }
        
        [self.mainTitle, self.subTitle, self.idTitle, self.priceTitle, self.urlTitle]
            .forEach {
                self.stackView.addArrangedSubview($0)
            }
    }
    
    func infoViewDataSet(_ data: BookData) {
        self.mainTitle.text = data.mainTitle
        self.subTitle.text = data.subTitle
        self.priceTitle.text = data.price
        self.idTitle.text = data.bookID
        self.urlTitle.text = data.urlString
    }
}
