//
//  AppDelegate.swift
//  VEAudioKitDemo
//
//  Created by Pablo Balduz on 08/07/2019.
//  Copyright © 2019 Visual Engineering. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
        defer {
            window?.makeKeyAndVisible()
        }
        
        window?.rootViewController = ViewController()
        
        return true
    }

}

