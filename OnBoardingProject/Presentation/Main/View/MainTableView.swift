//
//  MainTableView.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import UIKit

class MainTableView: UITableView {
    lazy var refresh = UIRefreshControl().then {
        $0.tintColor = .label
    }
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        attribute()
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
}
