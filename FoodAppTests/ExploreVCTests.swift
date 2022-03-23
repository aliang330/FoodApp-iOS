//
//  ExploreVCTests.swift
//  FoodAppTests
//
//  Created by Allen Liang on 3/20/22.
//

import XCTest
import CoreLocation
@testable import FoodApp

class ExploreVCTests: XCTestCase {
    
    var sut: ExploreVC!

    override func setUpWithError() throws {
        let viewModel = ExploreViewModel(yelpApi: YelpApiStub())
        sut = ExploreVC(viewModel: viewModel)
        sut.loadViewIfNeeded()
    }

    override func tearDownWithError() throws {
        sut = nil
    }
    
    func test_viewDidLoad_configuresViewModel() {
        XCTAssertNotNil(sut.viewModel)
    }

    func test_viewDidLoad_configuresCollectionView() {
        XCTAssertIdentical(sut.collectionView.delegate, sut)
        XCTAssertNotNil(sut.dataSource, "dataSource")
        XCTAssertNotNil(sut.dataSource.supplementaryViewProvider, "dataSource supplementaryViewProvider")
    }
    
    func test_viewDidLoad_CollectionViewInitialState() {
        XCTAssertEqual(sut.numberOfSections(), 3)
        XCTAssertEqual(sut.numberOfHeaders(), 1)
        XCTAssertEqual(sut.numberOfCategories(), SampleData.foodCategories.count)
        XCTAssertEqual(sut.numberOfRestaurants(), 0)
    }
    
    func test_viewDidLoad_RendersRestaurantsFromViewModel() {
        let sampleRestaurants: [Business] = [
            makeRestaurant(name: "resturant1", address: "1 sesame street"),
            makeRestaurant(name: "resturant2", address: "2 sesame street"),
        ]
        
        sut.viewModel.restaurants = sampleRestaurants
        sut.viewModel.restaurantsChangedHandler?()

        let exp = expectation(description: "wait for api")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
        
        XCTAssertEqual(sut.numberOfRestaurants(), 2)
        XCTAssertEqual(sut.restaurantName(atItem: 0), "resturant1")
        XCTAssertEqual(sut.restaurantName(atItem: 1), "resturant2")
        XCTAssertEqual(sut.address(atItem: 0), "1 sesame street")
        XCTAssertEqual(sut.address(atItem: 1), "2 sesame street")
        
    }
    
    func test_viewWillAppear_configuresNavBar() {
        let _ = embedInNavigationController(controller: sut)
        sut.viewWillAppear(true)
        
        let exp = expectation(description: "wait for nav bar to hide")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
        
        XCTAssertTrue(sut.navigationController!.navigationBar.isHidden)
        XCTAssertEqual(sut.navigationItem.largeTitleDisplayMode, .never)
        XCTAssertTrue(sut.navigationController!.navigationBar.prefersLargeTitles)
    }
    
    func test_viewWillAppear_configuresTabBarController() {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [sut]
        
        sut.viewWillAppear(true)
        
        XCTAssertIdentical(tabBarController.delegate, sut)
    }
    
    func test_viewDidDisappear_removesSelfAsTabBarControllerDelegate() {
        let tabBarController = UITabBarController()
        tabBarController.viewControllers = [sut]
        sut.viewWillDisappear(true)
        
        XCTAssertNil(tabBarController.delegate)
    }
    
    func test_viewDidLoad_fetchRestaurantFails() {
        let mockAPI = YelpApiStub()
        mockAPI.fetchRestaurantsInLocationResult = .failure(.badRequest)
        sut = ExploreVC()
        sut.loadViewIfNeeded()
        
        XCTAssertEqual(sut.numberOfRestaurants(), 0)
    }
    
    func test_didSelectRestaurant_pushRestaurantDetailVC() {
        let nav = embedInNavigationController(controller: sut)
        let sampleRestaurants: [Business] = [
            makeRestaurant(name: "resturant1", address: "1 sesame street"),
            makeRestaurant(name: "resturant2", address: "2 sesame street"),
        ]
        
        sut.viewModel.restaurants = sampleRestaurants
        sut.viewModel.restaurantsChangedHandler?()
        
        let indexPath = IndexPath(item: 0, section: ExploreVC.Section.nearByRestaurants.rawValue)
        sut.collectionView(sut.collectionView, didSelectItemAt: indexPath)
        
        let exp = expectation(description: "wait nav transistion")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
        
        let detailVC = nav.topViewController as? RestaurantDetailVC
        
        XCTAssertTrue(nav.topViewController is RestaurantDetailVC)
        XCTAssertEqual(detailVC?.viewModel.restaurant, sampleRestaurants[0])
    }
    
    func test_tapSearchBar_pushesModalSearchController() {
        let nav = embedInNavigationController(controller: sut)
        
        sut.didTapSearchBar()
        
        let exp = expectation(description: "wait nav transistion")
        exp.isInverted = true
        wait(for: [exp], timeout: 0.5)
        
        XCTAssertTrue(nav.topViewController is ModalSearchController)
    }
        
    // Helper methods
    
    private func makeRestaurant(name: String, address: String) -> Business {
        var restaurant = Business(name: name, latitude: 10, longitude: 10)
        restaurant.location = YelpLocation(display_address: [address])
        
        return restaurant
    }
    
    private func embedInNavigationController(controller: UIViewController) -> NavigationController {
        let nav = NavigationController(rootViewController: controller)
        return nav
    }
    
}

private extension ExploreVC {
    func numberOfRestaurants() -> Int {
        return collectionView.numberOfItems(inSection: Section.nearByRestaurants.rawValue)
    }
    
    func numberOfCategories() -> Int {
        return collectionView.numberOfItems(inSection: Section.categories.rawValue)
    }
    
    func numberOfSections() -> Int {
        return collectionView.numberOfSections
    }
    
    func numberOfHeaders() -> Int {
        return collectionView.numberOfItems(inSection: Section.header.rawValue)
    }
    
    func restaurantName(atItem item: Int) -> String? {
        let indexPath = IndexPath(item: item, section: Section.nearByRestaurants.rawValue)
        let cell = dataSource.collectionView(self.collectionView, cellForItemAt: indexPath) as? RestaurantCell
        return cell?.restaurantNameLabel.text
    }
    
    func address(atItem item: Int) -> String? {
        let indexPath = IndexPath(item: item, section: Section.nearByRestaurants.rawValue)
        let cell = dataSource.collectionView(self.collectionView, cellForItemAt: indexPath) as? RestaurantCell
        return cell?.addressLabel.text
    }
}

class YelpApiStub: YelpApi {
    var fetchRestaurantsInLocationResult: Result<[Business], FAError>?
    var downloadImageForRestaurantResult: UIImage?
    
    func fetchRestaurantsInLocation(searchTerm: String?, coordinates: CLLocationCoordinate2D?, location: String?, page: Int, perPage: Int, completion: @escaping (Result<[Business], FAError>) -> ()) {
        if fetchRestaurantsInLocationResult == nil { return }
        DispatchQueue.main.async {
            completion(self.fetchRestaurantsInLocationResult!)
        }
    }
    
    func downloadImageForRestaurant(from imageUrlString: String, completion: @escaping (UIImage?) -> ()) {
        completion(downloadImageForRestaurantResult)
    }
}
