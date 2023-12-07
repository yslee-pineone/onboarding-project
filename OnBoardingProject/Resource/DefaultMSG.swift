//
//  DefaultMSG.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

enum DefaultMSG: String {
    enum Main: String {
        case title = "New Books"
    }
    
    enum Detail: String {
        case title = "Detail Book"
        case loading = "로딩 중입니다."
        case memoPlaceHolder = "메모를 입력해보세요."
        case keyboardDonBtn = "확인"
    }
    
    enum Search: String {
        case title = "Search Books"
        case isEmpty = "검색된 항목이 없습니다."
        case searchStart = "검색어를 입력해보세요."
    }
    case error = "에러가 발생했습니다."
}
