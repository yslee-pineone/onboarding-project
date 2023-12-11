//
//  WebViewModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/11/23.
//

import Foundation

import RxSwift
import RxCocoa

class WebViewModel {
    let bookTitle: String
    let bookURL: URL
    
    struct Input {
        
    }
    
    struct Output {
        let loadingURL: Driver<URL>
    }
    
    func transform(input: Input) -> Output {
        return Output(
            loadingURL: .just(bookURL)
        )
    }
    
    init(
        title: String,
        bookURL: URL
    ){
        self.bookTitle = title
        self.bookURL = bookURL
    }
}
