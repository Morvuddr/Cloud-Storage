//
//  ResourceCollectionViewCell.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 03/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class ResourceCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var resourceNameLabel: UILabel!
    
    var resource: Resource?
    
    func setup(_ resource: Resource? = nil){
        self.resource = resource
        if resource?.type == "dir"{
            icon.image = UIImage(named: "typeFolder.png")
        } else {
            icon.image = UIImage(named: "typeFile.png")
        }
        resourceNameLabel.text = resource?.name
    }
    
}

extension UICollectionViewCell {
    
    class var identifier: String {
        return String(describing: self)
    }
    
}
