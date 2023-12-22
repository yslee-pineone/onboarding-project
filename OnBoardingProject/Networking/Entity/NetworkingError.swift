//
//  NetworkingError.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/8/23.
//

import Foundation

enum NetworkingError: String, Error {
    /// 파싱에러
    case error_400 = "데이터를 파싱할 수 없습니다."
    /// 알 수 없는 에러
    case error_499 = "알 수 없는 문제가 발생했습니다."
    
    /// 서버오류
    case error_500 = "서버에 문제가 발생하여 데이터를 로드할 수 없습니다."
    
    /// 값 없음
    case error_800 = "로딩된 결과가 없습니다."
    
    /// 네트워크 안됨
    case error_999 = "네트워크에 연결되어 있지 않습니다."
    
    /// 기본 에러
    case defaultError = "오류가 발생하였습니다."
    
    var errorMSG: String {
        self.rawValue
    }
}
