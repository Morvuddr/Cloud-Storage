//
//  AddResourceViewController.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 06/07/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit

class AddResourceViewController: UIViewController {
    
    
    @IBOutlet weak var addView: UIView!
    @IBOutlet weak var resourceNameTextField: UITextField!
    
    var resource: Resource?
    var completion: ((Resource, String)->())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addView.layer.cornerRadius = 20
        addView.layer.borderWidth = 1
        resourceNameTextField.delegate = self

    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func addButtonTapped(_ sender: Any) {
        if (resourceNameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)!{
            resourceNameTextField.placeholder = "Введите название"
            return
        }
        let resourceName = self.resourceNameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        self.dismiss(animated: true) {
            self.completion!(self.resource!, resourceName)
        }
    }
    
}

extension AddResourceViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 255
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        return newText.trimmingCharacters(in: .whitespacesAndNewlines).count <= maxLength
    }
}
