//
//  SettingsTableViewController.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 01/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    @IBOutlet weak var userNameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.delaysContentTouches = false;
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if User.currentUser != nil {
            userNameLabel.text = User.currentUser?.userName
        }
    }

    @IBAction func doLogout(_ sender: Any) {
        let actionSheetController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel, handler: nil)
        let logoutAction = UIAlertAction(title: "Выйти", style: .destructive) { (action) in
            
            let tabBarController = self.tabBarController?.viewControllers![0] as! UINavigationController
            let firstTab = tabBarController.topViewController as! ResourcesCollectionViewController
            firstTab.notificationToken?.invalidate()
            ResourceFunctions.shared.deleteAll()
            YandexClient.shared.logout()
        }
        actionSheetController.addAction(cancelAction)
        actionSheetController.addAction(logoutAction)
        self.present(actionSheetController, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
}
