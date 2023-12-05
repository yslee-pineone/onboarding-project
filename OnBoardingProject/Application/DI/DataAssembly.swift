//
//  DataAssembly.swift
//  OnBoardingProject
//
//  Created by pineone-yslee on 12/5/23.
//

import Foundation

import Swinject

struct DataAssembly: Assembly {
    func assemble(container: Swinject.Container) {
        container.register(NetworkServiceProtocol.self) { _ in
            NetworkService()
        }
        
        container.register(BookListLoadProtocol.self) { container in
            BookListLoad(networkService: container.resolve(NetworkServiceProtocol.self)!)
        }
    }
}
