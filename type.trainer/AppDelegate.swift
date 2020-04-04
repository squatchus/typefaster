//
//  AppDelegate.swift
//  type.trainer
//
//  Created by Sergey Mazulev on 01.04.2020.
//  Copyright © 2020 Suricatum. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var coordinator: AppCoordinator?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        let rootNC = UINavigationController()
        rootNC.navigationBar.isHidden = true
        window?.rootViewController = rootNC
        window?.makeKeyAndVisible()
        coordinator = AppCoordinator()
        coordinator?.start(with: window!)
        
        return true
    }
   
}
