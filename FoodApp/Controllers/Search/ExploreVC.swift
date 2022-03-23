//
//  SearchCollectionView.swift
//  FoodApp
//
//  Created by Allen Liang on 3/4/22.
//

import UIKit
import CoreLocation



class ExploreVC: UICollectionViewController {
    typealias DataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>
    typealias SectionSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>
    
    enum Section: Int, CaseIterable {
        case header
        case categories
        case nearByRestaurants
    }
    
    var viewModel: ExploreViewModel
    var dataSource: DataSource!

    init(viewModel: ExploreViewModel = ExploreViewModel()) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: ExploreVC.createLayout())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewModel()
        configureDataSource()
        configureSupplementaryViewProvider()
        configureCollectionView()
        setupInitialSnapshot()
    }
    
    func configureViewModel() {
        viewModel.restaurantsChangedHandler = updateNearByRestaurants
        viewModel.fetchRestaurantsFromApi()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        configureTabBarController()
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.delegate = nil
    }
    
    func configureTabBarController() {
        tabBarController?.delegate = self
    }
    
    func configureNavBar() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func configureDataSource() {
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            guard let self = self else { fatalError("self is nil") }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("unknown section") }
            
            switch section {
            case .header:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchHeaderCell.reuseID, for: indexPath) as! SearchHeaderCell
                cell.delegate = self
                return cell
            case .categories:
                guard let category = item as? FoodCategory else { fatalError() }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FoodCategoryCell.reuseID, for: indexPath) as! FoodCategoryCell
                cell.set(category: category)
                return cell
            case .nearByRestaurants:
                guard let restaurant = item as? Business else { fatalError() }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RestaurantCell.reuseID, for: indexPath) as! RestaurantCell
                cell.set(restaurant: restaurant)
                cell.addShadow()
                return cell
            }
        })
    }
    
    func configureSupplementaryViewProvider() {
        self.dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseID, for: indexPath) as! SectionHeader
            guard let sectionKind = Section(rawValue: indexPath.section) else { fatalError("unknown section") }
            
            switch sectionKind {
            case .header:
                fatalError("no section header in header")
            case .categories:
                header.label.text = "Categories"
            case .nearByRestaurants:
                header.label.text = "Near You"
            }
            
            return header
        }
    }
    
    func configureCollectionView() {
        collectionView.refreshControl = UIRefreshControl()
        collectionView.refreshControl?.addTarget(self, action: #selector(refreshView), for: .valueChanged)
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(FoodCategoryCell.self, forCellWithReuseIdentifier: FoodCategoryCell.reuseID)
        collectionView.register(SearchHeaderCell.self, forCellWithReuseIdentifier: SearchHeaderCell.reuseID)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: SectionHeader.kind, withReuseIdentifier: SectionHeader.reuseID)
        collectionView.register(RestaurantCell.self, forCellWithReuseIdentifier: RestaurantCell.reuseID)
    }
    
    @objc func refreshView() {
        viewModel.refreshRestaurants {
            self.collectionView.refreshControl?.endRefreshing()
        }
    }
    
    static func createLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionNumber, env in
            guard let sectionKind = Section(rawValue: sectionNumber) else { return nil }
            
            switch sectionKind {
            case .header:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(260)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.orthogonalScrollingBehavior = .continuous
                section.contentInsets.bottom = 8
                
                return section
            case .categories:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1/4), heightDimension: .fractionalHeight(1.0)))
                item.contentInsets.trailing = 8
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
                section.orthogonalScrollingBehavior = .continuous
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: SectionHeader.kind, alignment: .topLeading)]
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40)), elementKind: SectionHeader.kind, alignment: .topLeading, absoluteOffset: .init(x: 8 , y: 0))]
                
                return section
            case .nearByRestaurants:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
                item.contentInsets.bottom = 30
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(240)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = .init(top: 0, leading: 16, bottom: 0, trailing: 16)
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40)), elementKind: SectionHeader.kind, alignment: .topLeading, absoluteOffset: .init(x: 8, y: 0))]
                
                return section
            }
        }
    }
    
    func setupInitialSnapshot() {
        let sections = Section.allCases
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyHashable>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot)
        
        var headerSnapshot = SectionSnapshot()
        headerSnapshot.append(["header"])
        dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)
        
        var categorySnapshot = SectionSnapshot()
        categorySnapshot.append(SampleData.foodCategories)
        dataSource.apply(categorySnapshot, to: .categories, animatingDifferences: false)
    }
    
    func updateNearByRestaurants() {
        var nearByRestaurantsSnapshot = SectionSnapshot()
        nearByRestaurantsSnapshot.append(viewModel.restaurants)
        self.dataSource.apply(nearByRestaurantsSnapshot, to: .nearByRestaurants, animatingDifferences: true)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        var insets = view.safeAreaInsets
        insets.top = 0
        collectionView.contentInset = insets
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.section == 2 {
            let restaurant = viewModel.restaurants[indexPath.item]
            let detailViewModel = RestaurantDetailViewModel(restaurant: restaurant)
            let detailVC = RestaurantDetailVC(viewModel: detailViewModel)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
    override func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height
        
        if offsetY > 0 && offsetY > (contentHeight - height) {
            viewModel.fetchRestaurantsFromApi()
        }
    }
}

extension ExploreVC: SearchCollectionViewHeaderDelegate {
    func didTapSearchBar() {
        let modalSearchController = ModalSearchController()
        modalSearchController.modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
        
        navigationController?.pushViewController(modalSearchController, animated: true)
    }
}

extension ExploreVC: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        if tabBarController.selectedIndex == 0 {
            scrollToTop()
        }
    }
    
    private func scrollToTop() {
        self.collectionView.setContentOffset(.init(x: 0, y: 0), animated: true)
    }
}
