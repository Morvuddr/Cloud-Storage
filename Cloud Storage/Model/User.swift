//
//  User.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 01/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation

class User {
    
    static let userDidLogoutNotification = "UserDidLogout"
    
    var userName: String?
    var accessToken: String?
    
    
    init(userName: String, accessToken: String){
        self.userName = userName
        self.accessToken = accessToken
    }
    
    static var _currentUser: User?
    
    class var currentUser: User? {
        get{
            if(_currentUser == nil){
                let defaults = UserDefaults.standard
                let userName = defaults.string(forKey: "userName")
                let accessToken = defaults.string(forKey: "accessToken")
                
                if let userName = userName, let accessToken = accessToken {
                    _currentUser = User(userName: userName, accessToken: accessToken)
                }
                
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user
            let defaults = UserDefaults.standard
            if let user = user {
                defaults.set(user.userName, forKey: "userName")
                defaults.set(user.accessToken, forKey: "accessToken")
            } else {
                defaults.set(nil, forKey: "userName")
                defaults.set(nil, forKey: "accessToken")
            }
        }
    }
    
}
