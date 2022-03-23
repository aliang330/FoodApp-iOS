//
//  YelpApi.swift
//  FoodApp
//
//  Created by Allen Liang on 3/21/22.
//

import UIKit
import CoreLocation

protocol YelpApi {
    func fetchRestaurantsInLocation(searchTerm: String?,
                                    coordinates: CLLocationCoordinate2D?,
                                    location: String?,
                                    page: Int,
                                    perPage: Int,
                                    completion: @escaping (Result<[Business],FAError>) -> ())
    
    func downloadImageForRestaurant(from imageUrlString: String, completion: @escaping (UIImage?) -> ())
}
