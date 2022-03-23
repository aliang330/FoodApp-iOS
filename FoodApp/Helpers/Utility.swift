//
//  Utility.swift
//  FoodApp
//
//  Created by Allen Liang on 3/11/22.
//

import UIKit

struct Utility {
    static func setupTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
        UITabBar.appearance().tintColor = .red
    }
    
    static func createTabBarController() -> UITabBarController {
        let tabBarController = UITabBarController()
        
        let searchVC = UINavigationController(rootViewController: ExploreVC())
        searchVC.tabBarItem = UITabBarItem(title: "Search", image: UIImage(systemName: "magnifyingglass"), tag: 0)

        let wishlistVC = UINavigationController(rootViewController: WishlistVC())
        wishlistVC.tabBarItem = UITabBarItem(title: "Wishlist", image: .init(systemName: "star.fill"), tag: 1)

        tabBarController.viewControllers = [searchVC, wishlistVC]
        
        setupTabBarAppearance()
        
        return tabBarController
    }
    
    static func checkIsCurrentLocationString(text: String) -> Bool {
        return text.lowerCasedWithoutWhiteSpace == Strings.currentLocation
    }
}
