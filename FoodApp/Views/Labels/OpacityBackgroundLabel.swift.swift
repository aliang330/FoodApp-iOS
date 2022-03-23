//
//  OpacityBackgroundLabel.swift.swift
//  FoodApp
//
//  Created by Allen Liang on 3/7/22.
//

import Foundation
import UIKit

class OpacityBackgroundLabel: UIView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(text: String) {
        self.init(frame: .zero)
        label.text = text
    }
    
    func setText(text: String) {
        label.text = text
    }
    
    func configure() {
        self.backgroundColor = .black
        self.layer.opacity = 0.3
        
        label.numberOfLines = 1
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .bold)
        
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.constraintToViewBounds(view: self)
    }
}

