//
//  RestaurantDetailHeaderCell.swift
//  FoodApp
//
//  Created by Allen Liang on 3/6/22.
//

import UIKit

class RestaurantDetailHeaderCell: UICollectionViewCell {
    static let reuseID = "restaurantDetailHeaderCell"
    
    let restaurantImageView = ImageViewWithGradient()
    let restaurantNameLabel = UILabel()
    let addressLabel = UILabel()
    let openWithYelpButton = LeadingIconButton(text: "Open With Yelp", image: .init(named: "yelp"))
    
    weak var delegate: RestaurantDetailVCDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        configure()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    
    func configure() {
        addSubview(restaurantImageView)
        addSubview(openWithYelpButton)
        
        restaurantImageView.addSubview(restaurantNameLabel)
        restaurantImageView.addSubview(addressLabel)
        
        restaurantImageView.translatesAutoresizingMaskIntoConstraints = false
        restaurantNameLabel.translatesAutoresizingMaskIntoConstraints = false
        addressLabel.translatesAutoresizingMaskIntoConstraints = false
        openWithYelpButton.translatesAutoresizingMaskIntoConstraints = false

        openWithYelpButton.addTarget(self, action: #selector(handleYelpButtonTapped), for: .touchUpInside)
        
        restaurantImageView.backgroundColor = .backgroundGray
        restaurantImageView.contentMode = .scaleAspectFill
        restaurantImageView.clipsToBounds = true
        
        restaurantNameLabel.font = .systemFont(ofSize: 30, weight: .bold)
        restaurantNameLabel.textColor = .white
        restaurantNameLabel.numberOfLines = 2
        
        addressLabel.font = .systemFont(ofSize: 14)
        addressLabel.textColor = .backgroundGray
        
        let bottomSeparatorLine = UIView()
        bottomSeparatorLine.backgroundColor = .lightGray
        bottomSeparatorLine.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomSeparatorLine)
        bottomSeparatorLine.contraintAsBottomSeparatorLine(to: self)
        
        NSLayoutConstraint.activate([
            restaurantImageView.topAnchor.constraint(equalTo: topAnchor),
            restaurantImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            restaurantImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            restaurantImageView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 3/4),

            restaurantNameLabel.leadingAnchor.constraint(equalTo: restaurantImageView.leadingAnchor, constant: 16),
            restaurantNameLabel.bottomAnchor.constraint(equalTo: addressLabel.topAnchor, constant: -8),
            restaurantNameLabel.trailingAnchor.constraint(equalTo: restaurantImageView.trailingAnchor, constant: -16),
            restaurantNameLabel.heightAnchor.constraint(lessThanOrEqualTo: restaurantImageView.heightAnchor, multiplier: 1/2),

            
            addressLabel.bottomAnchor.constraint(equalTo: restaurantImageView.bottomAnchor, constant: -8),
            addressLabel.leadingAnchor.constraint(equalTo: restaurantNameLabel.leadingAnchor),
            addressLabel.trailingAnchor.constraint(equalTo: restaurantNameLabel.trailingAnchor),
            addressLabel.heightAnchor.constraint(equalToConstant: 20),
            
            openWithYelpButton.topAnchor.constraint(equalTo: restaurantImageView.bottomAnchor, constant: 28),
            openWithYelpButton.leadingAnchor.constraint(equalTo: restaurantImageView.leadingAnchor, constant: 32),
            openWithYelpButton.trailingAnchor.constraint(equalTo: restaurantImageView.trailingAnchor, constant: -32),
            openWithYelpButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        openWithYelpButton.addShadow()
        restaurantImageView.bringSubviewToFront(restaurantNameLabel)
        
    }
    
    @objc func handleYelpButtonTapped() {
        delegate?.didTapOpenWithYelp()
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
}

extension UIView {
    func constraintToViewBounds(view: UIView) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func addShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = .init(width: 0, height: 2)
        self.layer.shadowRadius = 5
    }
    
    func addLabelShadow() {
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 1.0
        self.layer.shadowOffset = .init(width: 0, height: 0)
        self.layer.shadowRadius = 10
    }
}
