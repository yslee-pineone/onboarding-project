//
//  UIStackView+.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/11/23.
//

import UIKit

extension UIStackView {
    func addArrangedSubviews(_ views: [UIView]) {
        views.forEach {
            addArrangedSubview($0)
        }
    }
}
