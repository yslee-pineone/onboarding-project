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
        $0.layer.cornerRadius = 20
        $0.backgroundColor = .lightGray
    }
    
    let bookImageView = UIImageView()
    
    let browserIcon = UIImageView().then {
        $0.image = UIImage(systemName: "safari")
    }
    
    let stackView = UIStackView().then {
        $0.backgroundColor = .gray
        $0.distribution = .equalSpacing
        $0.alignment = .fill
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
        $0.font = .systemFont(ofSize: FontStyle.small.ofSize)
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.attribute()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension StandardTableViewCell {
    private func attribute() {
        self.backgroundColor = .clear
    }
    
    private func layout() {
        self.addSubview(self.mainView)
        self.mainView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(PaddingStyle.standard.ofSize)
        }
        
        [self.bookImageView, self.stackView, self.browserIcon]
            .forEach {
                self.mainView.addSubview($0)
            }
        
        self.bookImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview().inset(PaddingStyle.standard.ofSize)
            $0.height.equalTo(60)
        }
        
        self.stackView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(self.bookImageView)
            $0.top.equalTo(self.bookImageView.snp.bottom).offset(PaddingStyle.standard.ofSize)
        }
        
        self.browserIcon.snp.makeConstraints {
            $0.width.equalTo(24)
            $0.height.equalTo(24)
            $0.top.trailing.equalToSuperview().inset(PaddingStyle.standard.ofSize)
        }
        
        [self.mainTitle, self.subTitle, self.idTitle, self.priceTitle]
            .forEach {
                self.stackView.addArrangedSubview($0)
            }
    }
    
    func cellDataSet(data: BookData) {
        self.mainTitle.text = data.title
        self.subTitle.text = data.subtitle
        self.priceTitle.text = data.price
        self.idTitle.text = data.isbn13
        self.bookImageView.kf.setImage(with: data.imageURL)
    }
}
