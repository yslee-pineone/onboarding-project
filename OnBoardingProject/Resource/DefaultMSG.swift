//
//  DefaultMSG.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

struct DefaultMSG {
    struct Main {
        static let title = "New Books"
    }
    
    struct Detail {
        static let title = "Detail Book"
        static let loading = "로딩 중입니다."
        static let memoPlaceHolder = "메모를 입력해보세요."
        static let keyboardDonBtn = "확인"
    }
    
    struct Search {
        static let title = "Search Books"
        static let isEmpty = "검색된 항목이 없습니다."
        static let searchStart = "검색어를 입력해보세요."
    }
    
    struct Error {
        static let defaultError = "에러가 발생했습니다."
    }
    
}
