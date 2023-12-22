//
//  UserDefaultError.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

enum UserDefaultError: String, Error {
    case notContents = "검색 내역이 없습니다."
    case searchWordSaveOff = "검색어 저장이 꺼져있습니다."
    case defaultError = "오류가 발생하였습니다."
    
    var errorMSG: String {
        self.rawValue
    }
    
    static let defaultErrorMSG = "오류가 발생하였습니다."
}
