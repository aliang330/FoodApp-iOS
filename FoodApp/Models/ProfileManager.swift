//
//  ProfileManager.swift
//  FoodApp
//
//  Created by Allen Liang on 3/10/22.
//

import UIKit

class ProfileManager {
    
    static var lastWidgetRefreshDate: Date? {
        UserDefaults.standard.object(forKey: UserDefaultConstants.lastWidgetDataRefreshDate) as? Date
    }
    
    static func setDefaultZipCode(zipCode: String) {
        UserDefaults.standard.set(zipCode, forKey: UserDefaultConstants.defaultZipCode)
    }
    
    //TODO: change to computed property
    static func getDefaultZipCode() -> String {
        return UserDefaults.standard.string(forKey: UserDefaultConstants.defaultZipCode) ?? "02110"
    }
    //TODO: change to computed property
    static func isOnboarding() -> Bool {
        return !UserDefaults.standard.bool(forKey: UserDefaultConstants.onboardingComplete)
    }

    static func onboardingComplete() {
        UserDefaults.standard.set(true, forKey: UserDefaultConstants.onboardingComplete)
    }
    
    static func setWidgetRefreshDate(date: Date) {
        UserDefaults.standard.set(date, forKey: UserDefaultConstants.lastWidgetDataRefreshDate)
    }
}
