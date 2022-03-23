//
//  SearchRestaurantListVC.swift
//  FoodApp
//
//  Created by Allen Liang on 3/11/22.
//

import UIKit
import CoreLocation

class SearchRestaurantListVC: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, Business>
    
    enum Section: Int {
        case main
    }
    
    var searchTerm: String
    var location: String
    var coordinates: CLLocationCoordinate2D?
    var page = 0
    var restaurants: [Business] = []
    var dataSource: DataSource!
    
    init(searchTerm: String, location: String, coordinates: CLLocationCoordinate2D?) {
        self.searchTerm = searchTerm
        self.location = location
        self.coordinates = coordinates
        super.init(collectionViewLayout: SearchRestaurantListVC.createCollectionViewLayout())
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        fetchRestaurants()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
    }
    
    func configureNavBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.tintColor = .yelpRed
        navigationItem.title = "\"\(searchTerm)\""
    }
    
    func configureCollectionView() {
        collectionView.delegate = self
        collectionView.backgroundColor = .white
        collectionView.register(RestaurantCell.self, forCellWithReuseIdentifier: RestaurantCell.reuseID)
    }
    
    func configureDataSource() {
        dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RestaurantCell.reuseID, for: indexPath) as! RestaurantCell
            cell.set(restaurant: item)
            cell.addShadow()
            return cell
        })
    }
    
    func updateData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Business>()
        snapshot.appendSections([.main])
        snapshot.appendItems(restaurants)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func fetchRestaurants() {
        NetworkManager.shared.fetchRestaurantsInLocation(searchTerm: searchTerm, coordinates: coordinates, location: location, page: page, perPage: 10) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print(error)
            case .success(let restaurants):
                self.restaurants.appendUniques(contentsOf: restaurants)
                self.updateData()
            }
        }
    }
    
    static func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        let layout = UICollectionViewCompositionalLayout { sectionNumber, env in
            let item = NSCollectionLayoutItem(layoutSize: .init(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .fractionalHeight(1.0)))
            item.contentInsets.bottom = 30
            
            let group = NSCollectionLayoutGroup.vertical(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(240)), subitems: [item])
            
            let section = NSCollectionLayoutSection(group: group)
            section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
            
            return section
        }
        return layout
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > 0 && offsetY > (contentHeight - height) {
            page += 1
            fetchRestaurants()
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let restaurant = restaurants[indexPath.item]
        let viewModel = RestaurantDetailViewModel(restaurant: restaurant)
        let detailVC = RestaurantDetailVC(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
}

