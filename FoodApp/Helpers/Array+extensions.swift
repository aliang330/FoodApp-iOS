//
//  Array+extensions.swift
//  FoodApp
//
//  Created by Allen Liang on 3/11/22.
//

import Foundation

extension Array {
    mutating func appendUniques<S>(contentsOf newElements: S) where Element == S.Element, S : Sequence, S.Element : Hashable {
        let set = Set<Element>(self)
        newElements.forEach {
            if !set.contains($0) { self.append($0) }
        }
    }
}
