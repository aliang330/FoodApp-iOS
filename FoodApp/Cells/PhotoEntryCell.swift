//
//  PhotoEntryCell.swift
//  FoodApp
//
//  Created by Allen Liang on 3/14/22.
//

import UIKit

class PhotoEntryCell: UICollectionViewCell {
    static let reuseID = "photoEntryCell"
    
    let imageView = ImageViewWithGradient(frame: .zero)
    let captionLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        imageView.addSubview(captionLabel)
        addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        
        captionLabel.textColor = .white
        captionLabel.text = ""
        captionLabel.numberOfLines = 1
        captionLabel.font = .systemFont(ofSize: 16, weight: .bold)
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = bounds
        
        imageView.constraintToViewBounds(view: self)
        
        NSLayoutConstraint.activate([
            captionLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor, constant: 4),
            captionLabel.trailingAnchor.constraint(equalTo: imageView.trailingAnchor,constant: -4),
            captionLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -4),
            captionLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    func set(entry: PhotoEntry) {
        let image = PersistenceManager.loadUserImageFromFileSystem(path: entry.imageUrl)
        DispatchQueue.main.async {
            self.captionLabel.text = entry.caption
            self.imageView.image = image
        }
    }
}
