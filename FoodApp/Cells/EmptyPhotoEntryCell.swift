//
//  EmptyPhotoEntryCell.swift
//  FoodApp
//
//  Created by Allen Liang on 3/8/22.
//

import Foundation
import UIKit

class EmptyPhotoEntryCell: UICollectionViewCell {
    static let reuseID = "emptyPhotoEntryCell"
    
    let label = UILabel()
    let addPhotoButton = UIButton(type: .system)
    var addPhotoHandler: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .white
        label.textColor = .lightGray
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.text = "You don't have any photos of this restaurant...yet 😉."
        label.numberOfLines = 3
        label.textAlignment = .center
        
        addPhotoButton.setTitle("Add a Photo", for: .normal)
        addPhotoButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        addPhotoButton.addTarget(self, action: #selector(addPhotoButtonTapped), for: .touchUpInside)
        
        let topSeparator = SeparatorLine()
        let bottomSeparator = SeparatorLine()
        
        addSubview(topSeparator)
        addSubview(bottomSeparator)
        addSubview(label)
        addSubview(addPhotoButton)
        
        label.translatesAutoresizingMaskIntoConstraints = false
        addPhotoButton.translatesAutoresizingMaskIntoConstraints = false
        
        topSeparator.contraintAsTopSeparatorLine(to: self)
        bottomSeparator.contraintAsBottomSeparatorLine(to: self)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),
            
            
            addPhotoButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 16),
            addPhotoButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }
    
    @objc func addPhotoButtonTapped() {
        addPhotoHandler?()
    }
}
 
class SeparatorLine: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        backgroundColor = .lightGray
        translatesAutoresizingMaskIntoConstraints = false
    }
}

extension UIView {
    func contraintAsTopSeparatorLine(to view: UIView) {
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.heightAnchor.constraint(equalToConstant: 0.25)
        ])
    }
    
    func contraintAsBottomSeparatorLine(to view: UIView) {
        NSLayoutConstraint.activate([
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            self.heightAnchor.constraint(equalToConstant: 0.25)
        ])
    }
}
