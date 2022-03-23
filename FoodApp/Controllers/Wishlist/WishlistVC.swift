//
//  WishlistVC.swift
//  FoodApp
//
//  Created by Allen Liang on 3/4/22.
//

import UIKit

class WishlistVC: UIViewController {
    
    let tableView = UITableView()
    var wishListEntries: [WishListEntry] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureTableView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        if let entries = PersistenceManager.fetchWishListEntries() {
            wishListEntries = entries
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    func configureNavBar() {
        navigationItem.title = "Wish List"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        
        let mapBarButton = UIBarButtonItem(title: "Map", style: .plain, target: self, action: #selector(showMap))
        mapBarButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = mapBarButton
    }
    
    func configureTableView() {
        view.addSubview(tableView)
        tableView.frame = view.bounds
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 80
        
        tableView.register(ModalSearchRestaurantCell.self, forCellReuseIdentifier: ModalSearchRestaurantCell.reuseId)
    }
    
    @objc func showMap() {
        let restaurants: [Business] = wishListEntries.map { Business(wishListEntry: $0) }
        let mapView = MapViewController(restaurants: restaurants)
        
        navigationController?.pushViewController(mapView, animated: true)
    }
}

extension WishlistVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return wishListEntries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ModalSearchRestaurantCell.reuseId) as! ModalSearchRestaurantCell
        let entry = wishListEntries[indexPath.row]
        cell.set(wishListEntry: entry)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let entry = wishListEntries[indexPath.row]
        let restaurant = Business(wishListEntry: entry)
        let viewModel = RestaurantDetailViewModel(restaurant: restaurant)
        let detailVC = RestaurantDetailVC(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        let entry = wishListEntries[indexPath.row]
        wishListEntries.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .left)
        
        PersistenceManager.shared.removeFromWishList(restaurantID: entry.restaurantID)
    }
}

