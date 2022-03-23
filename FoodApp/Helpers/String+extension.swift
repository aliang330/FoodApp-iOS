//
//  String+extension.swift
//  FoodApp
//
//  Created by Allen Liang on 3/10/22.
//

import Foundation

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
    
    var lowerCasedWithoutWhiteSpace: String {
        return self.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: " ", with: "")
            .lowercased()
    }
}
