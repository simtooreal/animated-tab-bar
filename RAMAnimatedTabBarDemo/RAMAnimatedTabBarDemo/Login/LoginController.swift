//
//  LoginViewController.swift
//  RAMAnimatedTabBarDemo
//
//  Created by Chase J Brignac on 2/14/20.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import UIKit
import FirebaseAuth
import Firebase

extension UITextField {
    func setLeftPaddingPoints(_ space: CGFloat) {
        let paddingView = UIView(frame:CGRect(x: 0, y: 0, width: space, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

class LoginController: UIViewController {
    
    var loginView: LoginView!
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white

        // Do any additional setup after loading the view.
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    func setupView() {
        let mainView = LoginView(frame: self.view.frame)
        self.loginView = mainView
        self.loginView.loginAction = loginPressed
        self.loginView.signupAction = signupPressed
        self.view.addSubview(loginView)
        loginView.setAnchor(top: view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
    }
    
    func loginPressed() {
        print("login button pressed")
        
        guard let phoneNumber = loginView.phoneTextField.text else { return }
        guard let password = loginView.passwordTextField.text else { return }
        
        let email = phoneNumber + "@gmail.com"
        
        //verifyPhoneNumber(phoneNumber: phoneNumber)
        
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("User: \(String(describing: user)) signed in")
                self.defaults.set(true, forKey: "UserIsLoggedIn")
                Analytics.logEvent(AnalyticsEventLogin, parameters: [
                    AnalyticsParameterMethod: self.method
                ])
                let mainController = UINavigationController(rootViewController: MainController())
                self.present(mainController, animated: true, completion: nil)
            }
        }
    }
    
    func signupPressed() {
        print("signup button pressed")
        let signUpController = SignUpController()
        present(signUpController, animated: true, completion: nil)
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
    
    func signInWithVerificationCode(verificationCode: String, signInSuccess:@escaping(Error?, AuthDataResult?)->()) {
        guard let verificationID = UserDefaults.standard.string(forKey: "authVerificationID") else {
            signInSuccess(nil, nil)
            return
        }
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: verificationID, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                debugPrint(error.localizedDescription)
            }
            
            signInSuccess(error, authResult)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
