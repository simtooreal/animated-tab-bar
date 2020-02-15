//
//  UIStackView+Extension.swift
//  RAMAnimatedTabBarDemo
//
//  Created by Chase J Brignac on 2/14/20.
//  Copyright © 2020 Ramotion. All rights reserved.
//

import UIKit

extension UIView {
    func createStackView(views: [UIView]) -> UIStackView {
            let stackView = UIStackView(arrangedSubviews: views)
            stackView.axis = .vertical
            stackView.distribution = .fillProportionally
            stackView.spacing = 10
            return stackView
        }
}
