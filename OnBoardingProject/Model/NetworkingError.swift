//
//  NetworkingError.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import Foundation

enum NetworkingError: Error {
    case error_500
    case error_600
    /// 인터넷 없음
    case error_900
}
