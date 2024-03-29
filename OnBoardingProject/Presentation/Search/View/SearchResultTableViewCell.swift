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
import RxSwift
import Reusable

class SearchResultTableViewCell: UITableViewCell, Reusable {
    
    // MARK: - Propertie
    
    private lazy var bookImageView = UIImageView().then {
        $0.contentMode = .scaleToFill
    }
    
    lazy var infoView = StandardInfoView()
    
    var bag = DisposeBag()
    
    // MARK: - init, prepareForReuse
    
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
    
    // MARK: - Methods
    
    private func attribute() {
        separatorInset = .init(top: 0, left: 0, bottom: 0, right: 0)
        selectionStyle = .none
    }
    
    private func layout() {
        contentView.addSubviews([bookImageView, infoView])
        
        bookImageView.snp.makeConstraints {
            $0.leading.top.equalToSuperview().inset(12)
            $0.width.equalTo(100)
            $0.height.equalTo(140)
        }
        
        infoView.snp.makeConstraints {
            $0.leading.equalTo(self.bookImageView.snp.trailing).offset(12)
            $0.top.bottom.trailing.equalToSuperview().inset(12)
        }
    }
    
    func cellDataSet(data: BookData) {
        infoView.infoViewDataSet(data)
        bookImageView.kf.setImage(with: data.imageURL)
    }
}
