//
//  SearchResult.swift
//  FoodApp
//
//  Created by Allen Liang on 3/5/22.
//

import Foundation

struct SearchResult: Codable {
    let total: Int
    let businesses: [Business]
}

struct Business: Codable, Hashable {
    let id: String
    let name: String
    let rating: Double
    let image_url: String
    var location: YelpLocation?
    let url: String?
    let coordinates: YelpCoordinate
    
    var address: String {
        self.location?.display_address?.joined(separator: ", ") ?? ""
    }
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.coordinates = YelpCoordinate(latitude: latitude, longitude: longitude)
        self.id = UUID().uuidString
        self.rating = 0.0
        self.image_url = ""
        self.location = nil
        self.url = nil
    }
    
    init(wishListEntry: WishListEntry) {
        self.id = wishListEntry.restaurantID
        self.name = wishListEntry.restaurantName
        self.rating = 0.0
        self.image_url = wishListEntry.restaurantImageUrl
        self.location = .init(display_address: [wishListEntry.restaurantAddress])
        self.url = wishListEntry.restaurantUrlString
        self.coordinates = YelpCoordinate(latitude: wishListEntry.latitude, longitude: wishListEntry.longitude)
    }
}

struct YelpLocation: Codable, Hashable {
    let display_address: [String]?
}

struct YelpCoordinate: Codable, Hashable {
    let latitude: Double
    let longitude: Double
}
