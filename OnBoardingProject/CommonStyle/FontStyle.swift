//
//  FontStyle.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

enum FontStyle: CGFloat {
    case small = 12
    case mid = 16
    case titleBig = 24
        
    var ofSize: CGFloat {
        self.rawValue
    }
}
