//
//  StandardTableViewCell.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import UIKit

import SnapKit
import Then
import Kingfisher

class StandardTableViewCell: UITableViewCell {
    let mainView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .systemGray6
    }
    
    let bookImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    let browserIcon = UIImageView().then {
        $0.image = UIImage(systemName: "safari")
    }
    
    let stackView = UIStackView().then {
        $0.layer.cornerRadius = 16
        $0.sideCornerRound([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        $0.layoutMargins = UIEdgeInsets(
            top: PaddingStyle.standard,
            left: PaddingStyle.standard,
            bottom: PaddingStyle.standard,
            right: PaddingStyle.standard
        )
        $0.isLayoutMarginsRelativeArrangement = true
        $0.backgroundColor = .systemGray5
        $0.spacing = 4
        $0.distribution = .equalCentering
        $0.alignment = .center
        $0.axis = .vertical
    }
    
    let mainTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.titleBig, weight: .semibold)
    }
    
    let subTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.mid)
    }
    
    let idTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall)
    }
    
    let priceTitle = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.midSmall, weight: .semibold)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        self.backgroundColor = .clear
        self.selectionStyle = .none
    }
    
    private func layout() {
        self.contentView.addSubview(self.mainView)
        self.mainView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(PaddingStyle.big)
            $0.top.bottom.equalToSuperview().inset(PaddingStyle.standard)
        }
        
        [self.bookImageView, self.stackView, self.browserIcon]
            .forEach {
                self.mainView.addSubview($0)
            }
        
        self.bookImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(PaddingStyle.standard)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(160)
        }
        
        self.stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(self.bookImageView.snp.bottom).offset(PaddingStyle.standard)
            $0.bottom.equalToSuperview()
        }
        
        self.browserIcon.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.top.trailing.equalToSuperview().inset(PaddingStyle.standard)
        }
        
        [self.mainTitle, self.subTitle, self.idTitle, self.priceTitle]
            .forEach {
                self.stackView.addArrangedSubview($0)
            }
        
        self.mainView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(PaddingStyle.standard)
        }
    }
    
    func cellDataSet(data: BookData) {
        self.mainTitle.text = data.mainTitle
        self.subTitle.text = data.subTitle
        self.priceTitle.text = data.price
        self.idTitle.text = data.bookID
        self.bookImageView.kf.setImage(with: data.imageURL)
    }
}
