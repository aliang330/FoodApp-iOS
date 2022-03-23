//
//  FAFakeSearchBar.swift
//  FoodApp
//
//  Created by Allen Liang on 3/4/22.
//

import UIKit

class FAFakeSearchBar: UIView {

    let searchIcon = UIImageView()
    let placeholderText = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .white
        addSubview(searchIcon)
        addSubview(placeholderText)
        
        searchIcon.image = UIImage(systemName: "magnifyingglass")
        searchIcon.tintColor = .black
        placeholderText.text = "Search for burgers, pizza, sushi, chicken, thai, mexican..."
        placeholderText.font = .systemFont(ofSize: 16)
        placeholderText.textColor = .lightGray
        
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        placeholderText.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchIcon.centerYAnchor.constraint(equalTo: centerYAnchor),
            searchIcon.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchIcon.widthAnchor.constraint(equalToConstant: 20),
            searchIcon.heightAnchor.constraint(equalToConstant: 20),
            
            placeholderText.centerYAnchor.constraint(equalTo: searchIcon.centerYAnchor),
            placeholderText.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor, constant: 16),
            placeholderText.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            placeholderText.heightAnchor.constraint(equalTo: heightAnchor)
        ])
    }

}
