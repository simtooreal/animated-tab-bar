//
//  SignUpView.swift
//  RAMAnimatedTabBarDemo
//
//  Created by Chase J Brignac on 2/15/20.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import UIKit

class SignUpView: UIView {
    
    let backgroundImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "bg5")
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    let nameTextField: UITextField = {
        let tf = UITextField(placeHolder: "Name")
        return tf
    }()
    
    let phoneTextField: UITextField = {
        let tf = UITextField(placeHolder: "Phone Number")
        return tf
    }()
    
    let ageTextField: UITextField = {
        let tf = UITextField(placeHolder: "Age (must be 13 or older)")
        return tf
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField(placeHolder: "Password")
        return tf
    }()
    
    let submitButton: UIButton = {
        let button = UIButton(title: "Submit", borderColor: UIColor.greenBorderColor)
        button.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        return button
    }()
    
    let cancelButton: UIButton = {
        let button = UIButton(title: "Cancel", borderColor: UIColor.redBorderColor)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        return button
    }()
    
    var submitAction: (() -> Void)?
    var cancelAction: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        let stackView = createStackView(views: [nameTextField, phoneTextField, ageTextField, passwordTextField, submitButton, cancelButton])
        
        self.addSubview(backgroundImageView)
        addSubview(stackView)
        
        backgroundImageView.setAnchor(top: self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0)
        stackView.setAnchor(width: self.frame.width - 60, height: 310)
        stackView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
    }
    
    @objc func handleSubmit() {
        submitAction?()
    }
    
    @objc func handleCancel() {
        cancelAction?()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not be implemented")
    }
}
