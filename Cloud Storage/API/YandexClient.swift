//
//  YandexClient.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 01/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import OAuthSwift

class YandexClient {
    
    static let shared = YandexClient()
    
    let oauthswift = OAuth2Swift(
        consumerKey:    "aa970f1b0a264f0da2b4a6087d2c1b1d",
        consumerSecret: "",
        authorizeUrl:   "https://oauth.yandex.ru/authorize?",
        responseType:   "token"
    )
    
    weak var delegate: YandexLoginDelegate?
    
    var loginSuccess: ((Bool)->())?
    var loginFailure: ((OAuthSwiftError)->())?
    
    func doLogin(_ userName: String, _ vc: UIViewController, success: @escaping (Bool)->(), failure:  @escaping (OAuthSwiftError)->()){
        loginSuccess = success
        loginFailure = failure
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.splashDelay = true
        
        oauthswift.allowMissingStateCheck = true
        oauthswift.authorizeURLHandler = SafariURLHandler(viewController: vc, oauthSwift: oauthswift)
        
        guard let cbURL = URL(string: "cloudstorage://token") else { return }
        
        oauthswift.authorize(withCallbackURL: cbURL, scope: "", state: "", parameters: ["login_hint":userName, "force_confirm":true], success: {
            (credential, response, parameters) in
            User.currentUser = User(userName: userName, accessToken: credential.oauthToken)
            self.loginSuccess?(false)
            //self.delegate?.continueLogin()
        }, failure: { (error) in
            self.loginFailure?(error)
        })
        
    }
    
    func logout(){
        User.currentUser = nil
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil)
    }
}
