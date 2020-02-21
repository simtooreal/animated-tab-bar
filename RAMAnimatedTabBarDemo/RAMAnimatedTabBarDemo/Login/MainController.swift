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
import CoreImage

class MainController: UIViewController {
    
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
    
    func fetchPhotos() {
        PHPhotoLibrary.requestAuthorization { status in
            switch status {
            case .authorized:
                var arrayOfPHAsset : [PHAsset] = []
                let fetchOptions = PHFetchOptions()
                // Add sortDescriptor so the lastest photos will be returned.
                let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
                fetchOptions.sortDescriptors = [sortDescriptor]
                let PHFetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions) as! PHFetchResult<AnyObject>
                print("Found \(PHFetchResult.count) PHFetchResults")
                var ids = [String]()
                PHFetchResult.enumerateObjects({ (object, count, stop) in
                    ids.append(object.localIdentifier)}
                )
//                var count = 0
//                for id in ids {
//                    // Get picture retrieves the image from the photo library based on the localIdentifier images size is limited to 300x400
//                    autoreleasepool {
//                        let candidateImage = getPicture(pictureIdentifier: id, pictureWidth: 300, pictureHeight: 400)
//                        let ciImage =  CIImage(image: candidateImage)
//                        // image processing here
//                    }
//                    count += 1
//                }
                PHFetchResult.enumerateObjects({(object: AnyObject!,
                            count: Int,
                            stop: UnsafeMutablePointer<ObjCBool>) in

                            if object is PHAsset{
                                let asset = object as! PHAsset
                                print(asset)
                                arrayOfPHAsset.append(asset)
                //                print("Inside  If object is PHAsset, This is number 1")
                //
                //                let imageSize = CGSize(width: asset.pixelWidth,
                //                                       height: asset.pixelHeight)
                //
                //                /* For faster performance, and maybe degraded image */
                //                let options = PHImageRequestOptions()
                //                options.deliveryMode = .fastFormat
                //                options.isSynchronous = true
                //
                //                imageManager.requestImage(for: asset,
                //                                                  targetSize: imageSize,
                //                                                  contentMode: .aspectFill,
                //                                                  options: options,
                //                                                  resultHandler: {
                //                                                    (image, info) -> Void in
                ////                                                    self.photo = image!
                ////                                                    /* The image is now available to us */
                ////                                                    self.addImgToArray(uploadImage: self.photo)
                //                                                    print("enum for image, This is number 2")
                //
                //                })

                            }
                        })
                        print("arrayOfPHAsset : \(arrayOfPHAsset), arrayOfPHAsset count : \(arrayOfPHAsset.count)")
                self.findFaces(arrayOfPHAsset: arrayOfPHAsset)
                //self.findFaces(allPhotos: allPhotos)
            case .denied, .restricted:
                print("Not allowed")
            case .notDetermined:
                // Should not see this when requesting
                print("Not determined yet")
            }
        }
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
        
//        let first = ContactsController.init(nibName: nil, bundle: nil)
//        let second = LoginController.init(nibName: nil, bundle: nil)
//
//        viewControllers = [first, second]
        
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
        fetchPhotos()
        
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
    
    func findFaces(arrayOfPHAsset: [PHAsset]) {
        print("now we need to find all the different faces")
        let accuracy = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let faceDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: accuracy)
        let options = PHContentEditingInputRequestOptions()
        options.isNetworkAccessAllowed = true
        for photo in arrayOfPHAsset {
            photo.requestContentEditingInput(with: options) { (contentEditingInput: PHContentEditingInput?, _) -> Void in
                let img = CIImage(contentsOf: contentEditingInput!.fullSizeImageURL!)
                let faces = faceDetector?.features(in: img!, options: [CIDetectorSmile:true])
                if !faces!.isEmpty
                {
                    for face in faces as! [CIFaceFeature]
                    {
                        let mouthShowing = "\nMouth is showing: \(face.hasMouthPosition)"
                        print(mouthShowing)
                    }
                    print("we've processed a photo")
                }
            }
        }
        print("done processing faces")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        //dispose any resources that can be recreated
    }
}
