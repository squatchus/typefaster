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
    private lazy var coordinator = AppCoordinator()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let rootNC = UINavigationController()
        rootNC.navigationBar.isHidden = true
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = rootNC
        window?.makeKeyAndVisible()
        coordinator.start(with: window!)
        return true
    }
    
}
