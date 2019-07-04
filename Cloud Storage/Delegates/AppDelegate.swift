//
//  AppDelegate.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 30/06/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import OAuthSwift
import Alamofire

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var splashDelay = false
    var manager: NetworkReachabilityManager?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        manager = Connectivity.configureConnectionListener()
        manager?.startListening()
        
        return true
    }
    
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        
        OAuthSwift.handle(url: url)
        return true
    }

    
}

func delay(_ delay:Double, closure:@escaping ()->()) {
    let when = DispatchTime.now() + delay
    DispatchQueue.main.asyncAfter(deadline: when, execute: closure)
}

func createDate(from oldDate: String) -> String {
    let dateFormatter = ISO8601DateFormatter()
    //dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss ZZ"
    // yyyy-MM-ddThh:mm:ssZZ
    dateFormatter.timeZone = TimeZone.current
    guard let date = dateFormatter.date(from: oldDate) else{
        fatalError("ERROR: Date conversion failed due to mismatched format.")
    }
    // New format for a date
    let newDateFormatter = DateFormatter()
    newDateFormatter.dateFormat = "dd MMMM yyyy HH:mm"
    newDateFormatter.locale = Locale(identifier: "ru_RU")
    return newDateFormatter.string(from: date)
}
