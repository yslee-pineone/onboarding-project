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
    lazy var mainView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .systemGray6
    }
    
    lazy var bookImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    lazy var browserIcon = UIImageView().then {
        $0.image = UIImage(systemName: "safari")
    }
    
    lazy var stackView = UIStackView().then {
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
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func layout() {
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(PaddingStyle.big)
            $0.top.bottom.equalToSuperview().inset(PaddingStyle.standard)
        }
        
        [bookImageView, stackView, browserIcon]
            .forEach {
                mainView.addSubview($0)
            }
        
        bookImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(PaddingStyle.standard)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(160)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(bookImageView.snp.bottom).offset(PaddingStyle.standard)
            $0.bottom.equalToSuperview()
        }
        
        browserIcon.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.top.trailing.equalToSuperview().inset(PaddingStyle.standard)
        }
        
        [mainTitle, subTitle, idTitle, priceTitle]
            .forEach {
                stackView.addArrangedSubview($0)
            }
        
        mainView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(PaddingStyle.standard)
        }
    }
    
    func cellDataSet(data: BookData) {
        mainTitle.text = data.mainTitle
        subTitle.text = data.subTitle
        priceTitle.text = data.price
        idTitle.text = data.bookID
        bookImageView.kf.setImage(with: data.imageURL)
    }
}
