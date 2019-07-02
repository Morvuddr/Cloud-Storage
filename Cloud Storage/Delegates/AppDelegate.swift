//
//  AppDelegate.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 30/06/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import OAuthSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var splashDelay = false


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        OAuthSwift.handle(url: url)
        return true
    }
    
//    func applicationHandle(url: URL) {
//        OAuthSwift.handle(url: url)
//    }
    
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

