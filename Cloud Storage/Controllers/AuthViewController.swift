//
//  AuthViewController.swift
//  Cloud Storage
//
//  Created by Игорь Бопп on 30/06/2019.
//  Copyright © 2019 Igor. All rights reserved.
//

import UIKit
import OAuthSwift

class AuthViewController: UIViewController {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emptyInputLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.layer.cornerRadius = 10
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
        
    }

    @IBAction func loginButtonTapped(_ sender: Any) {
        
        let userName = userNameTextField.text
        
        if (userName == "" || userName?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) == ""){
            emptyInputLabel.text = "Пустое поле ввода"
            return
        }
        
        YandexClient.shared.doLogin(userName!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines), self, success: { ok in
            self.dismiss(animated: true, completion: nil)
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.splashDelay = ok
        }) { (error) in
            var message = ""
            if error.errorCode == -5 {
                if error.underlyingMessage! == "access_denied"{
                    message = "доступ к Яндекс.Диску запрещен"
                } else {
                    message = "введен некорректный логин или email"
                }
            } else {
                message = "произошла системная ошибка"
            }
            let actionAlertController = UIAlertController(title: "Ошибка входа", message: "Не удалось выполнить вход в аккаунт, потому что \(message). Повторите попытку.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Понятно", style: .cancel, handler: nil)
            actionAlertController.addAction(action)
            DispatchQueue.main.async {
                self.present(actionAlertController, animated: true, completion: nil)
            }
        }
        
    }
    
}
