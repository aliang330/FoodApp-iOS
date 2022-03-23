//
//  PhotoEntry+CoreDataProperties.swift
//  FoodApp
//
//  Created by Allen Liang on 3/7/22.
//
//

import Foundation
import CoreData


extension PhotoEntry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PhotoEntry> {
        return NSFetchRequest<PhotoEntry>(entityName: "PhotoEntry")
    }

    @NSManaged public var restaurantID: String
    @NSManaged public var imageUrl: String
    @NSManaged public var caption: String
    @NSManaged public var dateAdded: Date

}

extension PhotoEntry : Identifiable {

}
