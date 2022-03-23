//
//  ModalSearchController.swift
//  FoodApp
//
//  Created by Allen Liang on 3/5/22.
//

import UIKit
import CoreLocation

class ModalSearchController: UIViewController {
    typealias DataSource = UITableViewDiffableDataSource<Section, Business>
    
    enum Section {
        case main
    }
    
    let searchBar = UIView()
    let backButton = UIButton(frame: .zero)
    let searchTF = UITextField()
    let locationBar = UIView()
    let locationPinImage = UIImageView()
    let locationTF = UITextField()
    let tableView = UITableView()
    
    var dataSource: DataSource!
    var lastSearchedLocation = ""
    var isUsingCurrentLocation = false
    
    weak var searchTimer: Timer?
    var searchResults: [Business] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureDataSource()
        configureTableView()
        layoutUI()
        configureLocationTF()
        
        
        searchTF.becomeFirstResponder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
        title = "Search"
        updateLocationAuth()
    }
    
    func updateLocationAuth() {
        isUsingCurrentLocation = LocationManager.shared.isAuthorized
    }
    
    func configureDataSource() {
        self.dataSource = DataSource(tableView: tableView, cellProvider: { tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ModalSearchRestaurantCell.reuseId, for: indexPath) as! ModalSearchRestaurantCell
            cell.set(restaurant: item)
            return cell
        })
    }
    
    func configureTableView() {
        tableView.backgroundColor = .white
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.rowHeight = 80
        
        tableView.register(ModalSearchRestaurantCell.self, forCellReuseIdentifier: ModalSearchRestaurantCell.reuseId)
    }
    
    func configureLocationTF() {
        if LocationManager.shared.isAuthorized {
            let attributedString = NSAttributedString(string: "Current Location", attributes: [
                .foregroundColor: UIColor.systemBlue
            ])
            locationTF.attributedText = attributedString
            isUsingCurrentLocation = true
        } else {
            locationTF.text = ProfileManager.getDefaultZipCode()
            isUsingCurrentLocation = false
        }
    }
    
    func layoutUI() {
        let views = [searchBar, backButton, searchTF, locationBar, locationPinImage, locationTF]
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        view.addSubview(searchBar)
        searchBar.addSubview(backButton)
        searchBar.addSubview(searchTF)
        
        view.addSubview(locationBar)
        locationBar.addSubview(locationPinImage)
        locationBar.addSubview(locationTF)
        
        searchBar.backgroundColor = .white
        searchBar.layer.borderColor = UIColor.lightGray.cgColor
        searchBar.layer.borderWidth = 1
        searchBar.layer.cornerRadius = 8
        
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .lightGray
        backButton.addTarget(self, action: #selector(handleBackButtonTapped), for: .touchUpInside)
        
        searchTF.textColor = .black
        searchTF.placeholder = "Chicken, pasta, sushi, etc."
        searchTF.font = .systemFont(ofSize: 14)
        searchTF.clearButtonMode = .whileEditing
        searchTF.delegate = self
        searchTF.tag = 0
        searchTF.returnKeyType = .search
        
        locationBar.backgroundColor = .white
        locationBar.layer.borderColor = UIColor.lightGray.cgColor
        locationBar.layer.borderWidth = 1
        locationBar.layer.cornerRadius = 8
        
        locationPinImage.image = UIImage(systemName: "mappin.and.ellipse")
        locationPinImage.tintColor = .systemBlue
        
        locationTF.textColor = .black
        locationTF.placeholder = "neighborhood, city, state or zip code"
        locationTF.font = .systemFont(ofSize: 14)
        locationTF.clearButtonMode = .whileEditing
        locationTF.delegate = self
        locationTF.tag = 1
        locationTF.returnKeyType = .search
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: locationBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBar.heightAnchor.constraint(equalToConstant: 44),
            
            backButton.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            backButton.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 20),
            backButton.heightAnchor.constraint(equalToConstant: 20),
            
            searchTF.centerYAnchor.constraint(equalTo: searchBar.centerYAnchor),
            searchTF.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 16),
            searchTF.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor, constant: -16),
            searchTF.heightAnchor.constraint(equalToConstant: 20),
            
            locationBar.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            locationBar.leadingAnchor.constraint(equalTo: searchBar.leadingAnchor),
            locationBar.trailingAnchor.constraint(equalTo: searchBar.trailingAnchor),
            locationBar.heightAnchor.constraint(equalTo: searchBar.heightAnchor),
            
            locationPinImage.centerYAnchor.constraint(equalTo: locationBar.centerYAnchor),
            locationPinImage.leadingAnchor.constraint(equalTo: locationBar.leadingAnchor, constant: 8),
            locationPinImage.widthAnchor.constraint(equalToConstant: 20),
            locationPinImage.heightAnchor.constraint(equalToConstant: 20),
            
            locationTF.centerYAnchor.constraint(equalTo: locationBar.centerYAnchor),
            locationTF.leadingAnchor.constraint(equalTo: locationPinImage.trailingAnchor, constant: 16),
            locationTF.trailingAnchor.constraint(equalTo: locationBar.trailingAnchor, constant: -16),
            locationTF.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    @objc func handleBackButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    func searchForRestaurants(for searchTerm: String, in locationString: String) {
        let isCurrentLocationString = Utility.checkIsCurrentLocationString(text: locationString)
        var coordinates: CLLocationCoordinate2D?
        
        if isCurrentLocationString && !LocationManager.shared.isAuthorized {
            return
        }
        if isCurrentLocationString {
            coordinates = LocationManager.shared.currentLocation?.coordinate
        }
        
        lastSearchedLocation = locationString
        
        NetworkManager.shared.fetchRestaurantsInLocation(searchTerm: searchTerm, coordinates: coordinates, location: locationString, page: 0, perPage: 6) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(_):
                break // handle error
            case .success(let restaurants):
                self.searchResults = restaurants
                self.updateDataSource(restaurants: self.searchResults)
            }
        }
    }
    
    func updateDataSource(restaurants: [Business]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Business>()
        snapshot.appendSections([.main])
        snapshot.appendItems(restaurants)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
    }
    
    func pushSearchRestaurantListVC(searchTerm: String, location: String) {
        var coordinates: CLLocationCoordinate2D?
        if useCurrentLocation(locationString: location) {
            if !hasLocationAuth() {
                showLocationSettingsAlert()
                return
            }
            coordinates = LocationManager.shared.currentLocation?.coordinate
        }
        let searchRestaurantListVC = SearchRestaurantListVC(searchTerm: searchTerm, location: location, coordinates: coordinates)
        navigationController?.pushViewController(searchRestaurantListVC, animated: true)
    }
    
    func useCurrentLocation(locationString: String) -> Bool {
        return Utility.checkIsCurrentLocationString(text: locationString)
    }
    
    func hasLocationAuth() -> Bool {
        return LocationManager.shared.isAuthorized
    }
    
    func showLocationSettingsAlert() {
        let alert = UIAlertController(title: "Location Not Enabled", message: "Make sure you've allowed access to FoodApp by opening Settings and checking Location.", preferredStyle: .alert)
        
        alert.addAction(.init(title: "OK", style: .cancel))
        alert.addAction(.init(title: "Settings", style: .default, handler: { action in
            guard let url = URL(string: UIApplication.openSettingsURLString) else {
               return
            }
            if UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url, options: [:])
            }
        }))
        
        present(alert, animated: true)
    }
}

extension ModalSearchController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let restaurant = searchResults[indexPath.row]
        let viewModel = RestaurantDetailViewModel(restaurant: restaurant)
        let detailVC = RestaurantDetailVC(viewModel: viewModel)
        navigationController?.pushViewController(detailVC, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

extension ModalSearchController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField.tag == 0 {
            searchTimer?.invalidate()
            guard let oldString = textField.text else { return true}
            let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!, with: string)
            
            if newString.isEmpty {
                searchResults = []
                updateDataSource(restaurants: [])
                return true
            }
            searchTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { [weak self] timer in
                guard let self = self else { return }
                self.searchForRestaurants(for: newString, in: self.locationTF.text ?? "")
            })
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        if textField == self.searchTF {
            searchResults = []
            updateDataSource(restaurants: [])
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            guard let text = textField.text else { return }
            if Utility.checkIsCurrentLocationString(text: text) {
                textField.text = ""
            }
            
            updateDataSource(restaurants: [])
        } else {
            let location = locationTF.text ?? ""
            let searchTerm = searchTF.text ?? ""
            if lastSearchedLocation != location && !searchTerm.isEmpty {
                searchForRestaurants(for: searchTerm, in: location)
            } else {
                updateDataSource(restaurants: self.searchResults)
            }
            
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.tag == 1 {
            guard let text = textField.text else { return }
            
            if isUsingCurrentLocation && text.isEmpty {
                let attributedString = NSAttributedString(string: "Current Location", attributes: [
                    .foregroundColor: UIColor.systemBlue
                ])
                locationTF.attributedText = attributedString
            }
            
            if text.lowerCasedWithoutWhiteSpace == "currentlocation" {
                let attributedString = NSAttributedString(string: "Current Location", attributes: [
                    .foregroundColor: UIColor.systemBlue
                ])
                locationTF.attributedText = attributedString
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let searchText = searchTF.text, let locationText = locationTF.text else { return false }
        
        if searchText.isEmpty && locationText.isEmpty {
            return false
        }
        if searchText.isEmpty {
            searchTF.becomeFirstResponder()
            return false
        }
        if locationText.isEmpty {
            locationTF.becomeFirstResponder()
            return false
        }
        pushSearchRestaurantListVC(searchTerm: searchText, location: locationText)
        return true
    }
}

