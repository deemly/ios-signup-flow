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
    
    func showMessage(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil))
            
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        signUpButton.isEnabled = false
        Deemly.OpenSignUpFlow(email: emailField.text ?? "", fullName: nameField.text ?? "",
                              presenter: self, completion: {
            self.signUpButton.isEnabled = true
            self.showMessage(NSLocalizedString("Sign-Up flow completed!", comment: ""))
        })
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
}
