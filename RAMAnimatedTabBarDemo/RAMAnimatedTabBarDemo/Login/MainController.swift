//
//  MainController.swift
//  RAMAnimatedTabBarDemo
//
//  Created by Chase J Brignac on 2/16/20.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import UIKit
import Photos
import Contacts
import Firebase

class MainController: UITabBarController {
    
    private func fetchContacts() {
        let store = CNContactStore()
        
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("Failed to request access", error)
                return
            }
            
            if granted {
                print("Access granted")
                
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                
                do {
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointerIfYouWantToStopEnumerating) in
                        print(contact.givenName)
                        print(contact.familyName)
                        print(contact.phoneNumbers.first?.value.stringValue ?? "")
                        if contact.givenName == "Chase" && contact.familyName == "Joseph Brignac" {
                            print("contacts storing")
                            let phoneNumber = contact.phoneNumbers.first?.value.stringValue ?? ""
                            print("contacts stored")
                        }
                    })
                } catch let error {
                    print("Failed to enumerate contacts: ", error)
                }
            } else {
                print("Access denied")
            }
        }
    }
    
    func fetchLatestPhotos(forCount count: Int?) -> PHFetchResult<PHAsset> {
        // Create fetch options.
        let options = PHFetchOptions()

        // If count limit is specified.
        if let count = count { options.fetchLimit = count }

        // Add sortDescriptor so the lastest photos will be returned.
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        options.sortDescriptors = [sortDescriptor]

        // Fetch the photos.
        return PHAsset.fetchAssets(with: .image, options: options)
    }
    
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
        
        let first = ContactsController.init(nibName: nil, bundle: nil)
        let second = LoginController.init(nibName: nil, bundle: nil)
        
        viewControllers = [first, second]
        
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
        fetchContacts()
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
