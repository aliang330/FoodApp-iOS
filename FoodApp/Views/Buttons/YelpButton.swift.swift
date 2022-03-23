//
//  YelpButton.swift.swift
//  FoodApp
//
//  Created by Allen Liang on 3/6/22.
//

import Foundation
import UIKit

class LeadingIconButton: UIButton {
    
    let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.textColor = .black
        label.font = .systemFont(ofSize: 20, weight: .medium)
        return label
    }()
    
    let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(label)
        addSubview(iconImageView)
        clipsToBounds = true
        layer.masksToBounds = false
        layer.cornerRadius = 8
        backgroundColor = .white
    }
    
    convenience init(text: String, image: UIImage?) {
        self.init(frame: .zero)
        set(text: text, image: image)
    }
    
    func set(text: String, image: UIImage?) {
        label.text = text
        iconImageView.image = image
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.sizeToFit()
        let iconSize: CGFloat = 20
        let iconX: CGFloat = (frame.size.width - label.frame.size.width - iconSize - 5) / 2
        iconImageView.frame = .init(x: iconX, y: (frame.size.height - iconSize) / 2, width: iconSize, height: iconSize)
        label.frame = .init(x: iconX + iconSize + 5, y: 0, width: label.frame.width, height: frame.size.height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
