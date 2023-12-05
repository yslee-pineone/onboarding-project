//
//  SceneDelegate.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

import Swinject

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var container: Container!
    var appCoordinator: AppCoordinator!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let rootNavigationController = UINavigationController()
        
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()
        
        self.container = Container()
        
        [
            MainAssembly(),
            DataAssembly()
        ].forEach { [weak self] con in
            let assembly = con as! Assembly
            assembly.assemble(container: self!.container!)
        }
        
        let dependency = AppCoordinator.Dependency(
            navigationController: rootNavigationController,
            container: container
        )
        
        self.appCoordinator = AppCoordinator(dependency: dependency)
        self.appCoordinator.start()
        
    }
}

