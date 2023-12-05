//
//  MainViewModel.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import Foundation

import RxSwift
import RxCocoa

class MainViewModel {
    let bookListLoad: BookListLoadProtocol
    
    init(
        bookListLoad: BookListLoadProtocol
    ) {
        self.bookListLoad = bookListLoad
    }
}
