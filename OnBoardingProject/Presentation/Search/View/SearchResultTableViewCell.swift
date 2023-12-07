//
//  SearchResultTableViewCell.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit

import SnapKit
import Then
import Kingfisher

class SearchResultTableViewCell: UITableViewCell {
    static let id = "SearchResultTableViewCell"
    
    let bookImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    let infoView = StandardInfoView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.layout()
        self.layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        self.separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        self.selectionStyle = .none
    }
    
    private func layout() {
        [self.bookImageView, self.infoView]
            .forEach {
                self.contentView.addSubview($0)
            }
        
        self.bookImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(PaddingStyle.standard.ofSize)
            $0.width.equalTo(100)
            $0.height.equalTo(140)
        }
        
        self.infoView.snp.makeConstraints {
            $0.leading.equalTo(self.bookImageView.snp.trailing).offset(PaddingStyle.standard.ofSize)
            $0.top.bottom.trailing.equalToSuperview().inset(PaddingStyle.standard.ofSize)
        }
    }
    
    func cellDataSet(data: BookData) {
        self.infoView.infoViewDataSet(data)
        self.bookImageView.kf.setImage(with: data.imageURL)
    }
}
