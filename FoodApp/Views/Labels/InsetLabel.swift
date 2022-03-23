//
//  InsetLabel.swift
//  FoodApp
//
//  Created by Allen Liang on 3/12/22.
//

import UIKit

class InsetLabel: UILabel {
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: UIEdgeInsets(top: 0, left: 4, bottom: 0, right: 4)))
    }
}
