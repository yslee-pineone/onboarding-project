//
//  UserDefaultError.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

enum UserDefaultError: Error {
    case notContents
    case searchWordSaveOff
    
    var errorMSG: String {
        switch self {
        case .notContents:
            return "검색 내역이 없습니다."
        case .searchWordSaveOff:
            return "검색어 저장이 꺼져있습니다."
        default:
            return UserDefaultError.defaultErrorMSG
        }
    }
    
    static let defaultErrorMSG = "오류가 발생하였습니다."
}
