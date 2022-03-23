//
//  YelpApiMainThreadAdapter.swift
//  FoodApp
//
//  Created by Allen Liang on 3/21/22.
//

import UIKit
import CoreLocation

class YelpApiMainThreadAdapter: YelpApi {
    let api: YelpApi
    
    init(api: YelpApi = NetworkManager.shared) {
        self.api = api
    }
    
    func fetchRestaurantsInLocation(searchTerm: String?, coordinates: CLLocationCoordinate2D?, location: String?, page: Int, perPage: Int, completion: @escaping (Result<[Business], FAError>) -> ()) {
        api.fetchRestaurantsInLocation(searchTerm: searchTerm, coordinates: coordinates, location: location, page: page, perPage: perPage) { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func downloadImageForRestaurant(from imageUrlString: String, completion: @escaping (UIImage?) -> ()) {
        api.downloadImageForRestaurant(from: imageUrlString) { image in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
}
