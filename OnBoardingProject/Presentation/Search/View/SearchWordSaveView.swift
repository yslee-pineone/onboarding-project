//
//  SearchWordSaveView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/12/23.
//

import UIKit
import Then
import SnapKit

class SearchWordSaveView: UIView {
    
    // MARK: - Propertie
    
    lazy var collectionView = UICollectionView(frame: .null, collectionViewLayout: UICollectionViewLayout()).then {
        $0.collectionViewLayout = collectionViewLayout()
        $0.register(cellType: SearchWordSaveViewCell.self)
        $0.backgroundColor = .systemBackground
    }
    
    lazy var titleLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.isHidden = true
        $0.font = UIFont.systemFont(ofSize: FontStyle.mid, weight: .semibold)
    }
    
    lazy var editBtn = UIButton(type: .system).then {
        $0.setImage(UIImage(systemName: "ellipsis"), for: .normal)
    }
    
    lazy var doneBtn = UIButton(type: .system).then {
        $0.titleLabel?.font = .systemFont(ofSize: FontStyle.small, weight: .semibold)
        $0.titleLabel?.numberOfLines = 2
        $0.setTitle("삭제\n완료", for: .normal)
        $0.isHidden = true
    }
    
    // MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        // 레이아웃 오류 방지 용
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.layout()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Methods
    
    private func layout() {
        addSubviews([collectionView, editBtn, doneBtn])
        editBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(48)
        }
        
        doneBtn.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview()
            $0.width.equalTo(48)
        }
        
        collectionView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.trailing.equalTo(editBtn.snp.leading).offset(-12)
        }
        
        collectionView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewCompositionalLayout{
        let itemSize = NSCollectionLayoutSize(widthDimension: .estimated(120), heightDimension: .absolute(80))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .estimated(120), heightDimension: .absolute(80))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    func editMode(isOn: Bool) {
        editBtn.isHidden = isOn
        doneBtn.isHidden = !isOn
    }
}
