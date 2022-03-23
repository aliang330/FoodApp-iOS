//
//  RestaurantDetailViewModel.swift
//  FoodApp
//
//  Created by Allen Liang on 3/22/22.
//

import Foundation

class RestaurantDetailViewModel {
    let restaurant: Business
    var photoEntries: [PhotoEntryWrapper] = []
    var isWishListed = false
    var persistenceManager: PersistenceServiceProvider
    var isChangingWishListStatus = false
    
    var isWishListedChangedHandler: ((Bool) -> ())?
    var photoEntriesChangedHandler: (([PhotoEntryWrapper]) ->())?
    
    init(restaurant: Business, persistenceManager: PersistenceServiceProvider = PersistenceManager.shared) {
        self.restaurant = restaurant
        self.persistenceManager = persistenceManager
        checkIfWishListed()
    }
    
    func checkIfWishListed() {
        isWishListed = persistenceManager.checkIfRestaurantInWishList(restaurantID: restaurant.id)
        isWishListedChangedHandler?(isWishListed)
    }
    
    func fetchPhotoEntries() {
        let fetchedPhotoEntries = persistenceManager.loadPhotoEntries(for: restaurant.id)
        photoEntries = fetchedPhotoEntries.map { PhotoEntryWrapper(photoEntry: $0) }
        photoEntriesChangedHandler?(photoEntries)
    }
    
    func addOrRemoveFromWishList() {
        if isChangingWishListStatus {
             return
        }
        isChangingWishListStatus = true
        if isWishListed {
            persistenceManager.removeFromWishList(restaurantID: restaurant.id)
            isChangingWishListStatus = false
            isWishListed = false
            isWishListedChangedHandler?(isWishListed)
        } else {
            persistenceManager.addRestaurantToWishList(restaurant: restaurant) { [weak self] error in
                guard let self = self else { return }
                if let error = error {
                    print(error)
                }
                self.isChangingWishListStatus = false
                self.isWishListed = true
                self.isWishListedChangedHandler?(self.isWishListed)
            }
        }
    }
}
