//
//  ExploreViewModel.swift
//  FoodApp
//
//  Created by Allen Liang on 3/22/22.
//

import Foundation

class ExploreViewModel {
    var restaurants: [Business] = []
    var yelpApi: YelpApi
    var page = 0
    var perPage = 10
    var isRefreshing = false
    
    var restaurantsChangedHandler: (() -> ())?
    
    init(yelpApi: YelpApi = YelpApiMainThreadAdapter()){
        self.yelpApi = yelpApi
    }
    
    func fetchRestaurantsFromApi() {
        let coordinates = LocationManager.shared.currentLocation?.coordinate
        let defaultZipCode = ProfileManager.getDefaultZipCode()
        
        yelpApi.fetchRestaurantsInLocation(searchTerm: nil, coordinates: coordinates, location: defaultZipCode, page: page, perPage: perPage) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
            case .success(let restaurants):
                self.restaurants.appendUniques(contentsOf: restaurants)
                self.page += 1
                self.restaurantsChangedHandler?()
            }
        }
    }
    
    func refreshRestaurants(completion: @escaping () -> ()) {
        restaurants.removeAll()
        page = 0
        restaurantsChangedHandler?()
        fetchRestaurantsFromApi()
        completion()
    }
}
