//
//  RestaurantCell.swift
//  FoodApp
//
//  Created by Allen Liang on 3/4/22.
//

import UIKit

class RestaurantCell: UICollectionViewCell {
    
    let containerView = UIView()
    let foodImageView = UIImageView()
    let restaurantNameLabel = UILabel()
    let ratingLabel = UILabel()
    let starIcon = UIImageView()
    let addressLabel = UILabel()
    let infoBackgroundView = UIView()
    
 
    static let reuseID = "restaurantCell"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        
        
        let views = [containerView, foodImageView, restaurantNameLabel, ratingLabel, starIcon, addressLabel, infoBackgroundView]
        
        for view in views {
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        
        addSubview(containerView)
        containerView.addSubview(foodImageView)
        containerView.addSubview(infoBackgroundView)
        
        infoBackgroundView.addSubview(restaurantNameLabel)
        infoBackgroundView.addSubview(starIcon)
        infoBackgroundView.addSubview(ratingLabel)
        infoBackgroundView.addSubview(addressLabel)
                
        containerView.backgroundColor = .green
        foodImageView.contentMode = . scaleAspectFill
        foodImageView.backgroundColor = .backgroundGray
        infoBackgroundView.backgroundColor = .white
        
        restaurantNameLabel.textColor = .black
        
        restaurantNameLabel.text = "Panda Castle"
        restaurantNameLabel.font = .systemFont(ofSize: 18, weight: .medium)
        starIcon.image = UIImage(named: "star")
        
        ratingLabel.textColor = .black
        ratingLabel.text = "4.8"
        ratingLabel.font = .systemFont(ofSize: 16, weight: .medium)
        
        addressLabel.textColor = .lightGray
        addressLabel.font = .systemFont(ofSize: 12)
        
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            foodImageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            foodImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            foodImageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            
            infoBackgroundView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            infoBackgroundView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            infoBackgroundView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            infoBackgroundView.heightAnchor.constraint(equalToConstant: 60),
            
            restaurantNameLabel.topAnchor.constraint(equalTo: infoBackgroundView.topAnchor, constant: 8),
            restaurantNameLabel.leadingAnchor.constraint(equalTo: infoBackgroundView.leadingAnchor, constant: 12),
            restaurantNameLabel.heightAnchor.constraint(equalTo: infoBackgroundView.heightAnchor, multiplier: 0.5),
            restaurantNameLabel.widthAnchor.constraint(equalTo: infoBackgroundView.widthAnchor, multiplier: 0.75),
            
            ratingLabel.trailingAnchor.constraint(equalTo: infoBackgroundView.trailingAnchor, constant: -12),
            ratingLabel.centerYAnchor.constraint(equalTo: restaurantNameLabel.centerYAnchor),
            ratingLabel.heightAnchor.constraint(equalToConstant: 20),
            
            starIcon.trailingAnchor.constraint(equalTo: ratingLabel.leadingAnchor, constant: -8),
            starIcon.centerYAnchor.constraint(equalTo: ratingLabel.centerYAnchor),
            starIcon.widthAnchor.constraint(equalToConstant: 20),
            starIcon.heightAnchor.constraint(equalToConstant: 20),
            
            addressLabel.leadingAnchor.constraint(equalTo: infoBackgroundView.leadingAnchor, constant: 12),
            addressLabel.bottomAnchor.constraint(equalTo: infoBackgroundView.bottomAnchor, constant: -8),
            addressLabel.trailingAnchor.constraint(equalTo: infoBackgroundView.trailingAnchor, constant: -8),
        ])
        
        containerView.layer.cornerRadius = 16
        containerView.clipsToBounds = true
    }
    
    func set(restaurant: Business) {
        restaurantNameLabel.text = restaurant.name
        ratingLabel.text = String(format: "%.1f", restaurant.rating)
        addressLabel.text = restaurant.address
        
        NetworkManager.shared.downloadImageForRestaurant(from: restaurant.image_url) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.foodImageView.image = image
            }
        }
    }
    
}
