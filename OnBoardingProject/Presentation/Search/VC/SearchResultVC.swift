//
//  SearchResultVC.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class SearchResultVC: UITableViewController {
    let noSearchListLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.isHidden = true
        $0.font = UIFont.systemFont(ofSize: FontStyle.mid.ofSize, weight: .semibold)
        $0.text = "검색된 항목이 없습니다."
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.attirbute()
        self.layout()
    }
}

private extension SearchResultVC {
    func attirbute() {
        self.tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.id)
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.backgroundColor = .systemBackground
        self.tableView.delegate = nil
        self.tableView.dataSource = nil
        self.tableView.separatorStyle = .none
    }
    
    func layout() {
        self.tableView.addSubview(self.noSearchListLabel)
        self.noSearchListLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(PaddingStyle.big.ofSize)
        }
    }
}
