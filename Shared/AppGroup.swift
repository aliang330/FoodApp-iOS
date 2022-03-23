//
//  AppGroup.swift
//  FoodApp
//
//  Created by Allen Liang on 3/17/22.
//

import Foundation

enum AppGroup: String {
    case main = "group.com.allenliang.FoodApp"
    
     var containerURL: URL {
        switch self {
        case .main:
            return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: self.rawValue)!
        }
    }
    
     var sharedImageURL: URL {
        switch self {
        case .main:
            return containerURL.appendingPathComponent("images")
        }
    }
    
    var widgetDataURL: URL {
        switch self {
        case .main:
            return containerURL.appendingPathComponent("widgetEntryData")
        }
    }
}
