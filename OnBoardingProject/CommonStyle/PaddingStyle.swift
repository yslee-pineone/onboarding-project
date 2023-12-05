//
//  PaddingStyle.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

enum PaddingStyle: CGFloat {
    case standard = 12
        
    var ofSize: CGFloat {
        self.rawValue
    }
}

