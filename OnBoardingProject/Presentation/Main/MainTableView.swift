//
//  MainTableView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import UIKit
import Then
import SnapKit

class MainTableView: UITableView {
    lazy var refresh = UIRefreshControl().then {
        $0.tintColor = .label
    }
    
    lazy var noSearchListLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.isHidden = true
        $0.font = UIFont.systemFont(ofSize: FontStyle.mid, weight: .semibold)
        $0.text = DefaultMSG.Main.empty
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        attribute()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute() {
        dataSource = nil
        delegate = nil
        
        separatorStyle = .none
        rowHeight = UITableView.automaticDimension
        register(StandardTableViewCell.self, forCellReuseIdentifier: StandardTableViewCell.id)
        backgroundColor = .systemBackground
        refreshControl = refresh
    }
    
    private func layout() {
        addSubview(noSearchListLabel)
        noSearchListLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(PaddingStyle.big)
        }
    }
}
