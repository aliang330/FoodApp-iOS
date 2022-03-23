//
//  NetworkManager.swift
//  FoodApp
//
//  Created by Allen Liang on 3/5/22.
//

import Foundation
import CoreLocation
import UIKit

enum FAError: String, Error {
    case invalidRequest
    case internetConnection
    case badRequest
    case invalidData
}



class NetworkManager: YelpApi {
    let imageCache = NSCache<NSString, UIImage>()
    
    static let shared = NetworkManager()
    let apiKey = ""

    func fetchRestaurantsInLocation(searchTerm: String?,
                                    coordinates: CLLocationCoordinate2D?,
                                    location: String?,
                                    page: Int,
                                    perPage: Int,
                                    completion: @escaping (Result<[Business],FAError>)->()) {

        var queryItems: [URLQueryItem] = [
            .init(name: "limit", value: "\(perPage)"),
            .init(name: "offset", value: "\(page * perPage)"),
        ]
        
        if let coordinates = coordinates {
            queryItems.append(contentsOf: [
                .init(name: "latitude", value: "\(coordinates.latitude)"),
                .init(name: "longitude", value: "\(coordinates.longitude)"),
            ])
        }
        
        if let searchTerm = searchTerm {
            queryItems.append(.init(name: "term", value: searchTerm))
        }
        
        if let location = location {
            queryItems.append(.init(name: "location", value: location))
        }
        
        var urlComponents = URLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "api.yelp.com"
        urlComponents.path = "/v3/businesses/search"
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            completion(.failure(.invalidRequest))
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let _ = error {
                completion(.failure(FAError.internetConnection))
                return
            }
            guard let response = response as? HTTPURLResponse, (200...299).contains(response.statusCode) else {
                completion(.failure(FAError.badRequest))
                return
            }
            guard let data = data else {
                completion(.failure(FAError.invalidData))
                return
            }
            
            do {
                let searchResult = try JSONDecoder().decode(SearchResult.self, from: data)
                completion(.success(searchResult.businesses))
            } catch {
                completion(.failure(FAError.invalidData))
            }
        }
        .resume()
        
    }
    
    func downloadImageForRestaurant(from imageUrlString: String, completion: @escaping (UIImage?)->()) {
        let cacheKey = NSString(string: imageUrlString)
        
        if let image = imageCache.object(forKey: cacheKey) {
            completion(image)
            return
        }
        
        guard let url = URL(string: imageUrlString) else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self,
                  error == nil,
                  let response = response as? HTTPURLResponse,
                  response.statusCode == 200,
                  let data = data else {
                      completion(nil)
                      return
                  }
            guard let image = UIImage(data: data) else {
                completion(nil)
                return
            }
            self.imageCache.setObject(image, forKey: cacheKey)
            completion(image)
        }
        .resume()
    }
}





