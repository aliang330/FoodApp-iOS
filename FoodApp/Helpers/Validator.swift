//
//  Validator.swift
//  FoodApp
//
//  Created by Allen Liang on 3/10/22.
//

import Foundation

struct Validator {
    static func isValidZipCode(zipCode: String) -> Bool {
        return zipCode.isInt && zipCode.count <= 11
    }
}
