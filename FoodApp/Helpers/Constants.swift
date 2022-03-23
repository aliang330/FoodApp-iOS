//
//  Constants.swift
//  FoodApp
//
//  Created by Allen Liang on 3/11/22.
//

import Foundation

enum UserDefaultConstants {
    static let defaultZipCode = "defaultZipCode"
    static let onboardingComplete = "onboardingComplete"
    static let lastWidgetDataRefreshDate = "lastWidgetDataRefreshDate"
}

enum Folders {
    static let images = FileManager.documentsDirectory.appendingPathComponent("images")
    static let restaurantImages = FileManager.documentsDirectory.appendingPathComponent("restaurantImages")
}

enum Strings {
    static let currentLocation = "currentlocation"
}
