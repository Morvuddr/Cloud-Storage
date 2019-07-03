//
//  SplashViewController.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 01/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class SplashViewController: UIViewController, YandexLoginDelegate {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    override func viewDidLoad() {
        super.viewDidLoad()
        YandexClient.shared.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if (!appDelegate.splashDelay){
            delay(1.0) {
                self.continueLogin()
            }
        }
        
    }
    
    func continueLogin() {
        appDelegate.splashDelay = false
        if User.currentUser == nil {
            showAuthViewController()
        } else {
            if Connectivity.isConnectedToInternet {
                ResourceFunctions.shared.deleteAll()
                YandexClient.shared.downloadMetaInfo(at: "/", for: nil, downloadSuccess: {
                    self.showApp()
                }) { (error) in
                    User.currentUser = nil
                    ResourceFunctions.shared.deleteAll()
                    UserDefaults.standard.set(error, forKey: "error")
                    self.continueLogin()
                }
            } else {
                showApp()
            }
        }
    }
    
    func showAuthViewController(){
        self.performSegue(withIdentifier: "showAuthViewController", sender: self)
    }
    
    func showApp(){
        self.performSegue(withIdentifier: "showApp", sender: self)
    }

}
