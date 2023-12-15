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
import Reusable

class SearchWordSaveViewCell: UICollectionViewCell, Reusable {
    private lazy var mainBG = UIView().then {
        $0.layer.cornerRadius = 16
        $0.backgroundColor = .systemGray5
    }
    
    private lazy var titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = .systemFont(ofSize: FontStyle.small)
        $0.textColor = .label
    }
    
    private var deleteBtn = UIButton(type: .system).then {
        $0.tintColor = .label
        $0.setImage(UIImage(systemName: "multiply"), for: .normal)
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
        
        deleteBtn.isHidden = true
    }
    
    private func attribute() {
        backgroundColor = .clear
    }
    
    private func layout() {
        contentView.addSubviews([mainBG, deleteBtn])
        mainBG.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
        
        deleteBtn.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.top.trailing.equalTo(mainBG).inset(4)
        }
        
        mainBG.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(6)
            $0.leading.trailing.equalToSuperview().inset(24)
        }
    }
    
    func cellSet(title: String, isEdit: Bool) {
        titleLabel.text = title
        deleteBtn.isHidden = !isEdit
    }
}
