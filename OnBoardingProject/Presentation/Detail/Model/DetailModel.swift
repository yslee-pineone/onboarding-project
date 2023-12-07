//
//  DetailModel.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/6/23.
//

import Foundation

import RxSwift

class DetailModel {
    let networkService: NetworkServiceProtocol
    
    init(
        networkService: NetworkServiceProtocol = NetworkService()
    ) {
        self.networkService = networkService
    }
    
    func detailBookDataRequest(id: String) -> Observable<BookData> {
        var urlComponents = URLComponents()
        urlComponents.scheme = URLRequestConfiguration.URL.scheme.rawValue
        urlComponents.host = URLRequestConfiguration.URL.host.rawValue
        urlComponents.path = URLRequestConfiguration.Detail.path.queryAdd(id: id)
        
        return self.networkService.request(
            urlComponents: urlComponents,
            decodingType: BookData.self
        )
        .map { data in
            guard case .success(let value) = data else {
                print("DATA LOADING ERROR")
                return BookData(
                    mainTitle: DefaultMSG.Error.defaultError,
                    subTitle: DefaultMSG.Error.defaultError,
                    bookID: "-1",
                    price: DefaultMSG.Error.defaultError,
                    imageString: DefaultMSG.Error.defaultError,
                    urlString: DefaultMSG.Error.defaultError
                )
            }
            return value
        }
        .asObservable()
    }
    
    func memoRequest(bookID id: String) -> Single<String> {
        Single<String>.create { single in
            if let contents = UserDefaults.standard.string(forKey: id) {
                single(.success(contents))
            } else {
                single(.failure(UserDefaultError.notContents))
            }
            
            return Disposables.create()
        }
    }
    
    func memoSave(bookID id:String, contents: String) {
        UserDefaults.standard.setValue(contents, forKey: id)
    }
}
