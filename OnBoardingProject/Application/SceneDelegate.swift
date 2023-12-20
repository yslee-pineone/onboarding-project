//
//  SceneDelegate.swift
//  OnBoardingProject
//
//  Created by pineone on 12/5/23.
//

import UIKit
import RxFlow

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    let flowCoordinator = FlowCoordinator()
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
    
        let appStepper = AppStepper()
        let appFlow = AppFlow(window: window!)
        
        flowCoordinator.coordinate(flow: appFlow, with: appStepper)
        window?.makeKeyAndVisible()
    }
}
