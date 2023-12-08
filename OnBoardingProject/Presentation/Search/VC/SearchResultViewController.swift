//
//  SearchResultViewController.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import UIKit

import RxSwift
import RxCocoa
import SnapKit
import Then

class SearchResultViewController: UITableViewController {
    lazy var noSearchListLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.isHidden = true
        $0.font = UIFont.systemFont(ofSize: FontStyle.mid, weight: .semibold)
        $0.text = DefaultMSG.Search.isEmpty
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attirbute()
        layout()
    }
    
    private func attirbute() {
        tableView.register(SearchResultTableViewCell.self, forCellReuseIdentifier: SearchResultTableViewCell.id)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = .systemBackground
        tableView.delegate = nil
        tableView.dataSource = nil
        tableView.separatorStyle = .none
    }
    
    private func layout() {
        tableView.addSubview(noSearchListLabel)
        noSearchListLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(PaddingStyle.big)
        }
    }
}
