//
//  NetworkingError.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import Foundation

enum NetworkingError: Error {
    /// 파싱에러
    case error_400
    /// 알 수 없는 에러
    case error_499
    
    /// 서버오류
    case error_500
    
    /// 네트워크 안됨
    case error_999
    
    var errorMSG: String {
        switch self {
        case .error_400:
            return "서버에 문제가 발생하여 데이터를 로드할 수 없습니다."
        default:
            return NetworkingError.defaultErrorMSG
        }
    }
    
    static let defaultErrorMSG = "오류가 발생하였습니다."
}