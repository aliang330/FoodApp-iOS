//
//  ErrorLabel.swift
//  FoodApp
//
//  Created by Allen Liang on 3/10/22.
//

import Foundation
import UIKit

class ErrorLabel: UIView {
    let icon = UIImageView()
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        clipsToBounds = true
        addSubview(icon)
        addSubview(label)

        icon.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        
        label.textColor = .red
        label.font = .systemFont(ofSize: 14)
        
        icon.image = UIImage(systemName: "exclamationmark.triangle")
        icon.tintColor = .red
        
        NSLayoutConstraint.activate([
            icon.centerYAnchor.constraint(equalTo: centerYAnchor),
            icon.leadingAnchor.constraint(equalTo: leadingAnchor),
            icon.widthAnchor.constraint(equalToConstant: 14),
            icon.heightAnchor.constraint(equalToConstant: 14),
            
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: icon.trailingAnchor, constant: 4),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func set(text: String) {
        label.text = text
    }
}
