//
//  AppDelegate.swift
//  CoreDataDemo
//
//  Created by Shashikant Jagtap on 21/10/2017.
//  Copyright © 2017 Shashikant Jagtap. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.


        window = UIWindow()
        window?.makeKeyAndVisible()

        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(identifier: "Users_ID")
//        let vc = sb.instantiateViewController(identifier: "Articles_ID")
        window?.rootViewController = vc

        return true
    }
}

