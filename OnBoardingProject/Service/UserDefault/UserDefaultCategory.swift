//
//  UserDefaultCategory.swift
//  OnBoardingProject
//
//  Created by 이윤수 on 12/21/23.
//

import Foundation

enum UserDefaultCategory {
    case searchKeyword
    case memo(id: String)
    case searchWordIsSave
    
    var key: String {
        switch self {
        case .searchKeyword:
            return "SearchWordSave"
            
        case .searchWordIsSave:
            return "SearchWordSaveOff"
            
        case .memo(let id):
            return id
        }
    }
}
