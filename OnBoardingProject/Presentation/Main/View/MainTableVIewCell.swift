//
//  MainTableVIewCell.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import UIKit

import SnapKit
import Then
import Kingfisher

class MainTableVIewCell: StandardTableViewCell {
    static let id = "MainTableVIewCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
