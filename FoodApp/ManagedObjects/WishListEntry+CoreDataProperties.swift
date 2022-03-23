//
//  WishListEntry+CoreDataProperties.swift
//  FoodApp
//
//  Created by Allen Liang on 3/7/22.
//
//

import Foundation
import CoreData


extension WishListEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WishListEntry> {
        return NSFetchRequest<WishListEntry>(entityName: "WishListEntry")
    }

    @NSManaged public var dateAdded: Date
    @NSManaged public var restaurantName: String
    @NSManaged public var restaurantID: String
    @NSManaged public var restaurantImagePath: String
    @NSManaged public var restaurantAddress: String
    @NSManaged public var restaurantUrlString: String
    @NSManaged public var restaurantImageUrl: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}

extension WishListEntry : Identifiable {

}
