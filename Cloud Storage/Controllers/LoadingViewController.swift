//
//  LoadingViewController.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 08/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var reasonLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var reason: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        loadingView.layer.cornerRadius = 15
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "ProcessCompleted"), object: nil, queue: OperationQueue.main) { notification in
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        reasonLabel.text = reason!
        activityIndicator.startAnimating()
    }
    override func viewWillDisappear(_ animated: Bool) {
        activityIndicator.stopAnimating()
    }
}
