//
//  SearchWordSaveViewCell.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/12/23.
//

import UIKit

import Then
import SnapKit
import RxSwift

class SearchWordSaveViewCell: UICollectionViewCell {
    static let id = "SearchwordSaveViewCell"
    
    let mainBG = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .systemGray5
    }
    
    let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.small)
        $0.textColor = .label
    }
    
    var bag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
    }
    
    private func layout() {
        contentView.addSubview(mainBG)
        mainBG.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(PaddingStyle.standard)
            $0.leading.trailing.equalToSuperview().inset(PaddingStyle.big)
        }
        
        mainBG.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(PaddingStyle.big)
        }
    }
}
