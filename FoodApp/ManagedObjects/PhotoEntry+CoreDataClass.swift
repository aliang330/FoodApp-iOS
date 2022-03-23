//
//  PhotoEntry+CoreDataClass.swift
//  FoodApp
//
//  Created by Allen Liang on 3/7/22.
//
//

import Foundation
import CoreData
import UIKit

@objc(PhotoEntry)
public class PhotoEntry: NSManagedObject {

    struct PhotoEntryData {
        let restaurantID: String
        let image: UIImage
        let imageName: String
        let caption: String
    }
    
    var isEmpty = false
    convenience init(isEmpty: Bool) {
        self.init()
        self.isEmpty = isEmpty
    }
    
    func set(restaurantID: String, imagePath: String, caption: String) {
        self.dateAdded = Date()
        self.restaurantID = restaurantID
        self.imageUrl = imagePath
        self.caption = caption
    }
}
