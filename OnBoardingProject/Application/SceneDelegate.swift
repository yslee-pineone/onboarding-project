//
//  SceneDelegate.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: AppCoordinator!
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        let rootNavigationController = UINavigationController()
        
        self.window?.rootViewController = rootNavigationController
        self.window?.makeKeyAndVisible()
        
        let dependency = AppCoordinator.Dependency(
            navigationController: rootNavigationController
        )
        
        self.appCoordinator = AppCoordinator(dependency: dependency)
        self.appCoordinator.start()
        
    }
}

