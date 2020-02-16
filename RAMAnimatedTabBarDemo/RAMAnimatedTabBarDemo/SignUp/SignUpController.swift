//
//  SignUpController.swift
//  RAMAnimatedTabBarDemo
//
//  Created by Chase J Brignac on 2/14/20.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController {
    var signUpView: SignUpView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        let signUpView = SignUpView(frame: self.view.frame)
        self.signUpView = signUpView
        self.signUpView.submitAction = submitPressed
        self.signUpView.cancelAction = cancelPressed
        view.addSubview(signUpView)
    }
    
    func submitPressed() {
        print("Submit button pressed")
        
        guard let phoneNumber = signUpView.phoneTextField.text else { return }
        guard let name = signUpView.nameTextField.text else { return }
        guard let password = signUpView.passwordTextField.text else { return }
        guard let age = signUpView.ageTextField.text else { return }
        
        verifyPhoneNumber(phoneNumber: phoneNumber)
        
        guard !phoneNumber.isEmpty else {
            return
        }
        
        let email = phoneNumber + "@gmail.com"
        
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            // completion handler
            if error != nil {
                print(error!.localizedDescription)
            } else {
                //success
                guard let uid = user?.user.uid else { return }
                print("Registration Successful ", uid)

                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    func LoginRequestComplete(success: Bool) {
        guard success else { return }
        
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "GoToVerification", sender: self)
        }
    }
    
    func cancelPressed() {
        dismiss(animated: true, completion: nil)
        print("Cancel button pressed")
    }
    
    func verifyPhoneNumber(phoneNumber: String) {
        let number = "+1" + phoneNumber
        
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                debugPrint(error.localizedDescription);
            } else {
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            }
        }
    }
    
    func getUniqueIDIfLoggedIn() -> String? {
        return Auth.auth().currentUser?.phoneNumber
    }
    
    static func signOut() {
        do {
            try Auth.auth().signOut()
        } catch let error {
            debugPrint(error)
        }
    }
}
