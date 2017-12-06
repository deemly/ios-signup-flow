//
//  ViewController.swift
//  Deemly Login
//
//  Created by Anders Borum on 06/12/2017.
//  Copyright © 2017 Anders Borum. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emailField.becomeFirstResponder()
    }
    
    func refreshButton() {
        let emailValid = (emailField.text ?? "").contains("@")
        let nameValid = (nameField.text ?? "").count > 0
        signUpButton.isEnabled = emailValid && nameValid
    }

    // MARK: UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // refresh button state in next run-loop when text contains changed values
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.refreshButton()
            
        }

        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField {
            nameField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        
        return true
    }

    // MARK: -
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? WebViewController {
            destination.email = (emailField.text ?? "").trimmingCharacters(in: .whitespaces)
            destination.name = (nameField.text ?? "").trimmingCharacters(in: .whitespaces)
        }
    }
}
