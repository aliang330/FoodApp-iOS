//
//  FileManager+extensions.swift
//  FoodApp
//
//  Created by Allen Liang on 3/16/22.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
