//
//  ImageViewWithGradient.swift
//  FoodApp
//
//  Created by Allen Liang on 3/12/22.
//

import UIKit

class ImageViewWithGradient: UIImageView {
    let myGradientLayer: CAGradientLayer
    
    override init(frame: CGRect) {
        myGradientLayer = CAGradientLayer()
        super.init(frame: frame)
        setup()
    }
    
    convenience init() {
        self.init(frame: .zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setup() {
            myGradientLayer.colors = [UIColor.black.withAlphaComponent(0.5).cgColor,
                                      UIColor.clear.cgColor,
                                      UIColor.black.withAlphaComponent(0.6).cgColor]
            myGradientLayer.locations = [0.0, 0.5, 1.0]

        self.layer.addSublayer(myGradientLayer)
    }
    
    override func layoutSubviews() {
        myGradientLayer.frame = self.layer.bounds
    }
}
