//
//  ModalSearchRestaurantCell.swift
//  FoodApp
//
//  Created by Allen Liang on 3/10/22.
//

import UIKit

class ModalSearchRestaurantCell: UITableViewCell {
    static let reuseId = "modalSearchRestaurantCell"
    
    let restaurantImageView = UIImageView()
    let restaurantNameLabel = UILabel()
    let addressLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .white
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        let views = [restaurantImageView, restaurantNameLabel, addressLabel]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        
        restaurantImageView.backgroundColor = .backgroundGray
        restaurantImageView.layer.cornerRadius = 8
        restaurantImageView.contentMode = .scaleAspectFill
        restaurantImageView.clipsToBounds = true
        
        restaurantNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        restaurantNameLabel.textColor = .black
        addressLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        addressLabel.textColor = .gray
        
        NSLayoutConstraint.activate([
            restaurantImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            restaurantImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            restaurantImageView.widthAnchor.constraint(equalToConstant: 50),
            restaurantImageView.heightAnchor.constraint(equalToConstant: 50),
            
            restaurantNameLabel.topAnchor.constraint(equalTo: restaurantImageView.topAnchor),
            restaurantNameLabel.leadingAnchor.constraint(equalTo: restaurantImageView.trailingAnchor, constant: 16),
            restaurantNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            restaurantNameLabel.heightAnchor.constraint(equalToConstant: 20),
            
            addressLabel.bottomAnchor.constraint(equalTo: restaurantImageView.bottomAnchor),
            addressLabel.leadingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: restaurantNameLabel.trailingAnchor),
            addressLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func set(restaurant: Business) {
        restaurantNameLabel.text = restaurant.name
        addressLabel.text = restaurant.address
        
        NetworkManager.shared.downloadImageForRestaurant(from: restaurant.image_url) { [weak self] image in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.restaurantImageView.image = image
            }
        }
    }
    
    func set(wishListEntry: WishListEntry) {
        restaurantNameLabel.text = wishListEntry.restaurantName
        addressLabel.text = wishListEntry.restaurantAddress
        restaurantImageView.image = PersistenceManager.loadUserImageFromFileSystem(path: wishListEntry.restaurantImagePath)
        
    }
}
