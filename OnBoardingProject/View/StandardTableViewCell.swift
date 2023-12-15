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
import RxSwift
import Reusable

class StandardTableViewCell: UITableViewCell, Reusable {
    private lazy var mainView = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .systemGray6
    }
    
    private lazy var bookImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    lazy var browserIcon = UIButton(type: .system).then {
        $0.setBackgroundImage(
            UIImage(systemName: "safari"),
            for: .normal
        )
    }
    
    private lazy var stackView = UIStackView().then {
        $0.layer.cornerRadius = 16
        $0.sideCornerRound([.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        $0.layoutMargins = UIEdgeInsets(
            top: 12,
            left: 12,
            bottom: 12,
            right: 12
        )
        $0.isLayoutMarginsRelativeArrangement = true
        $0.backgroundColor = .systemGray5
        $0.spacing = 4
        $0.distribution = .equalCentering
        $0.alignment = .center
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
    
    var bag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bag = DisposeBag()
    }
    
    private func attribute() {
        backgroundColor = .clear
        selectionStyle = .none
    }
    
    private func layout() {
        contentView.addSubview(mainView)
        mainView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview().inset(12)
        }
        
        mainView.addSubviews([bookImageView, stackView, browserIcon])
        
        bookImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(120)
            $0.height.equalTo(160)
        }
        
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(bookImageView.snp.bottom).offset(12)
            $0.bottom.equalToSuperview()
        }
        
        browserIcon.snp.makeConstraints {
            $0.width.equalTo(30)
            $0.height.equalTo(30)
            $0.top.trailing.equalToSuperview().inset(12)
        }
        
        stackView.addArrangedSubviews([mainTitle, subTitle, idTitle, priceTitle])
        
        mainView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
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
