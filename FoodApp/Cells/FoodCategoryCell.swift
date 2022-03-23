//
//  FoodCategoryCell.swift
//  FoodApp
//
//  Created by Allen Liang on 3/4/22.
//

import UIKit

class FoodCategoryCell: UICollectionViewCell {
    static let reuseID = "foodCategoryCell"
    
    let image = UIImageView()
    let categoryName = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        addSubview(image)
        addSubview(categoryName)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        categoryName.translatesAutoresizingMaskIntoConstraints = false
        
        categoryName.textColor = .black
        categoryName.textAlignment = .center
        categoryName.text = ""
        categoryName.font = .systemFont(ofSize: 16)
        
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: topAnchor),
            image.centerXAnchor.constraint(equalTo: centerXAnchor),
            image.widthAnchor.constraint(equalToConstant: 30),
            image.heightAnchor.constraint(equalToConstant: 30),
            
            categoryName.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 8),
            categoryName.leadingAnchor.constraint(equalTo: leadingAnchor),
            categoryName.trailingAnchor.constraint(equalTo: trailingAnchor),
            categoryName.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    func set(category: FoodCategory) {
        switch category {
        case .breakfast:
            categoryName.text = "Breakfast"
            image.image = UIImage(named: "pancakes")
        case .pizza:
            categoryName.text = "Pizza"
            image.image = UIImage(named: "pizza")
        case .mexican:
            categoryName.text = "Mexican"
            image.image = UIImage(named: "taco")
        case .chinese:
            categoryName.text = "Chinese"
            image.image = UIImage(named: "chinese-food")
        case .seafood:
            categoryName.text = "Seafood"
            image.image = UIImage(named: "shrimp")
        case .italian:
            categoryName.text = "Italian"
            image.image = UIImage(named: "spaguetti")
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
