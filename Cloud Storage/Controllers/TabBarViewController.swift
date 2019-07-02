//
//  TabBarViewController.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 01/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: User.userDidLogoutNotification), object: nil, queue: OperationQueue.main) { (notification) in
            self.dismiss(animated: true, completion: nil)
        }
        
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        appDelegate.tabBarController = self
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
