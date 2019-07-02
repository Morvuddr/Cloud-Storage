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
            showApp()
        }
    }
    
    func showAuthViewController(){
        self.performSegue(withIdentifier: "showAuthViewController", sender: self)
    }
    
    func showApp(){
//        let mainStoryboard = UIStoryboard(name: "AuthViewController", bundle: Bundle.main)
//        guard let destinationViewController = mainStoryboard.instantiateViewController(withIdentifier: "App") as? UITabBarController else {
//            return
//        }
//        destinationViewController.modalTransitionStyle = .crossDissolve
//        present(destinationViewController, animated: true, completion: nil)
        self.performSegue(withIdentifier: "showApp", sender: self)
    }

}
