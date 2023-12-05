//
//  UIView+.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import UIKit

extension UIView {
    func sideCornerRound(_ maskedCorners: CACornerMask){
        self.clipsToBounds = true
        self.layer.maskedCorners = CACornerMask(arrayLiteral: maskedCorners)
    }
}
