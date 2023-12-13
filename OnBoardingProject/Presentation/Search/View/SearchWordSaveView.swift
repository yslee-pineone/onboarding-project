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
    lazy var collectionView = UICollectionView(frame: .null, collectionViewLayout: UICollectionViewLayout()).then {
        $0.collectionViewLayout = collectionViewLayout()
        $0.register(SearchWordSaveViewCell.self, forCellWithReuseIdentifier: SearchWordSaveViewCell.id)
        $0.backgroundColor = .systemBackground
    }
    
    lazy var titleLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.isHidden = true
        $0.font = UIFont.systemFont(ofSize: FontStyle.mid, weight: .semibold)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
}
