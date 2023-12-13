//
//  SearchKeywordSection.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/13/23.
//

import Foundation

import RxDataSources

struct SearchKeywordSection {
    var items: [Item]
}

extension SearchKeywordSection: SectionModelType {
    typealias Item = String
    
    init(
        original: SearchKeywordSection,
        items: [Item]
    ) {
        self = original
        self.items = items
    }
}
