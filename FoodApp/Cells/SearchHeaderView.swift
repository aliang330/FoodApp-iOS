//
//  SearchHeaderView.swift
//  FoodApp
//
//  Created by Allen Liang on 3/4/22.
//

import UIKit

protocol SearchCollectionViewHeaderDelegate: AnyObject {
    func didTapSearchBar()
}

class SearchHeaderCell: UICollectionViewCell {

    static let reuseID = "searchHeaderCell"
    
    let headerContainerView = UIView()
    let headerView = UIImageView()
    let searchBarView = FAFakeSearchBar()
    
    weak var delegate: SearchCollectionViewHeaderDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        
        addSubview(headerContainerView)
        headerContainerView.addSubview(headerView)
        addSubview(searchBarView)
        headerContainerView.clipsToBounds = true
        
        headerView.contentMode = .scaleAspectFill
        headerView.image = UIImage(named: "shake-shack")
        
        searchBarView.addShadow()
        
        
        headerContainerView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        searchBarView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerContainerView.topAnchor.constraint(equalTo: topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -26),
            
            headerView.topAnchor.constraint(equalTo: headerContainerView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            
            searchBarView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -26),
            searchBarView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            searchBarView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            searchBarView.heightAnchor.constraint(equalToConstant: 52)
        ])
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSearchBarTapped))
        searchBarView.addGestureRecognizer(tapGesture)
        
    }
    
    @objc func handleSearchBarTapped() {
        delegate?.didTapSearchBar()
    }

}
