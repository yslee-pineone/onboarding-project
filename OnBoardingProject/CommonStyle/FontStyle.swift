//
//  FontStyle.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

enum FontStyle: CGFloat {
    case small = 10
    case midSmall = 14
    case mid = 16
    case titleBig = 18
        
    var ofSize: CGFloat {
        self.rawValue
    }
}
