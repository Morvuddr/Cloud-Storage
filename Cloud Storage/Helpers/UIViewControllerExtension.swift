//
//  UIViewControllerExtension.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 04/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
    /// Returns the initial view controller on a storyboard
    static func getInstance() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self))
    }
    
}
