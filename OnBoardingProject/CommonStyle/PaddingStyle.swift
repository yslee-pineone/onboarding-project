//
//  PaddingStyle.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

enum PaddingStyle: CGFloat {
    case standardHalf = 6
    case standard = 12
    case standardPlus = 18
    case big = 24
        
    var ofSize: CGFloat {
        self.rawValue
    }
}

