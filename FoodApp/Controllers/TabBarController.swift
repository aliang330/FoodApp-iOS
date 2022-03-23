//
//  TabBarController.swift
//  FoodApp
//
//  Created by Allen Liang on 3/10/22.
//

import Foundation
import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        let searchVC = NavigationController(rootViewController: ExploreVC())
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)

        let wishlistVC = NavigationController(rootViewController: WishlistVC())
        wishlistVC.tabBarItem = UITabBarItem(title: "Wishlist", image: .init(systemName: "star.fill"), tag: 1)

        viewControllers = [searchVC, wishlistVC]
    }
}


