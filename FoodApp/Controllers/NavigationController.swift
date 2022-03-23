//
//  NavigationController.swift
//  FoodApp
//
//  Created by Allen Liang on 3/17/22.
//

import UIKit

class NavigationController : UINavigationController {
    //changed status bar style according to each view controller
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let topVC = viewControllers.last {
            return topVC.preferredStatusBarStyle
        }
        return .default
    }
}
