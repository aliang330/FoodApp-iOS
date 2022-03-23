//
//  WishListEntry+CoreDataClass.swift
//  FoodApp
//
//  Created by Allen Liang on 3/7/22.
//
//

import Foundation
import CoreData

@objc(WishListEntry)
public class WishListEntry: NSManagedObject {
    func set(restaurant: Business) {
        self.restaurantID = restaurant.id
        self.restaurantName = restaurant.name
        self.restaurantAddress = restaurant.address
        self.restaurantImagePath = "restaurantImages/\(restaurantID).jpeg"
        self.dateAdded = Date()
        self.restaurantUrlString = restaurant.url ?? "www.yelp.com"
        self.restaurantImageUrl = restaurant.image_url
        self.latitude = restaurant.coordinates.latitude
        self.longitude = restaurant.coordinates.longitude
    }
}
