//
//  ResourcePropertiesViewController.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 04/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import Foundation
import UIKit

class ResourcePropertiesViewController: UIViewController {
    
    var resource: Resource?
    
    @IBOutlet weak var propertiesView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var resourceIcon: UIImageView!
    @IBOutlet weak var resourceNameLabel: UILabel!
    @IBOutlet weak var mimeTypeLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var createdLabel: UILabel!
    @IBOutlet weak var modifiedLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
        propertiesView.layer.cornerRadius = 20
        propertiesView.layer.borderWidth = 1
        borderView.layer.borderColor = UIColor.black.cgColor
        borderView.layer.borderWidth = 1
        
    }
    
    func setup(){
        resourceNameLabel.text = resource!.name
        if resource!.type == "dir"{
            resourceIcon.image = UIImage(named: "typeFolder.png")
            mimeTypeLabel.text = "Тип: Папка"
            sizeLabel.text = "Размер: неизвестно"
            
        } else {
            resourceIcon.image = UIImage(named: "typeFile.png")
            mimeTypeLabel.text = "Тип: " + resource!.mimeType
            sizeLabel.text = "Размер: \(resource!.size / 1024 / 1024) МБ"
        }
        createdLabel.text = "Создан: " + createDate(from: resource!.created)
        modifiedLabel.text = "Изменен: " + createDate(from: resource!.modified) 
        
    }

    @IBAction func closeButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
