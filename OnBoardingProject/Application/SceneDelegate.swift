//
//  SceneDelegate.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
    
        let tabbarController = TabbarController()
        
        window?.rootViewController = tabbarController
        window?.makeKeyAndVisible()
    }
}
