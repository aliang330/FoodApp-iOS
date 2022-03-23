//
//  SampleData.swift
//  FoodApp
//
//  Created by Allen Liang on 3/8/22.
//

import Foundation

enum FoodCategory {
    case breakfast
    case pizza
    case mexican
    case chinese
    case seafood
    case italian
}

struct SampleData {
    static var foodCategories: [FoodCategory] = [.breakfast,
                                                 .pizza,
                                                 .mexican,
                                                 .chinese,
                                                 .seafood,
                                                 .italian]
    
    static var restaurants: [Business] = [
        Business(name: "District Kitchen", latitude: 42.427632, longitude: -71.073631),
        Business(name: "Omori Izakaya", latitude: 42.423070, longitude: -71.063426),
        Business(name: "Crying Tiger", latitude: 42.4248607, longitude: -71.0647464)
    ]
}
