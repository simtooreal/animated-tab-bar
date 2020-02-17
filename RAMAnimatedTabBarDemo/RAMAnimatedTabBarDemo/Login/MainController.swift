//
//  MainController.swift
//  RAMAnimatedTabBarDemo
//
//  Created by Chase J Brignac on 2/16/20.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import UIKit
import Firebase

class MainController: UIViewController {
    
    let defaults = UserDefaults.standard
    var ref: DatabaseReference!
    
    var appUser: AppUser? {
        didSet {
            print("value set")
            guard let userName = appUser?.name else { return }
            navigationItem.title = userName
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ref = Database.database().reference()
        view.backgroundColor = .white
        
        let quotes = [
            "I Love You ❤️",
            "You are powerful",
            "You are beautiful",
            "You can do it",
            "Don't give up",
            "Vote for Bernie!",
            "Be kind"
        ]
        
        navigationItem.title = quotes.randomElement()!
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Log Out", style: .plain, target: self, action: #selector(logOut))
        fetchUserInfo()
    }
    
    @objc func logOut() {
        do {
            try Auth.auth().signOut()
            defaults.set(false, forKey: "UserIsLoggedIn")
            let loginController = UINavigationController(rootViewController: LoginController())
            present(loginController, animated: true, completion: nil)
        } catch let err {
            print(err.localizedDescription)
        }
        print("logged out")
    }
    
    func fetchUserInfo() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        ref.child("users").child(userId).observeSingleEvent(of: .value) { (snapshot) in
            guard let data = snapshot.value as? NSDictionary else { return }
            guard let username = data["name"] as? String else { return }
            self.appUser = AppUser(name: username, uid: userId)
        }
    }
}
