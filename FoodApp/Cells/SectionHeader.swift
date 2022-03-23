//
//  SectionHeader.swift
//  FoodApp
//
//  Created by Allen Liang on 3/17/22.
//

import UIKit

class SectionHeader: UICollectionReusableView {
    static let reuseID = "sectionHeader"
    static let kind = "categorySectionHeader"
    let label = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        label.textColor = .black
        label.text = ""
        label.font = .systemFont(ofSize: 20, weight: .bold)
        
        addSubview(label)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        label.frame = bounds
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
