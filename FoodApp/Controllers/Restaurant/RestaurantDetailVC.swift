//
//  RestaurantDetailView.swift
//  FoodApp
//
//  Created by Allen Liang on 3/5/22.
//

import UIKit
import SafariServices
import CoreData

protocol RestaurantDetailVCDelegate: AnyObject {
    func didTapOpenWithYelp()
}

class RestaurantDetailVC: UICollectionViewController {
    enum Section: Int, CaseIterable {
        case header
        case photos
    }
    
    let viewModel: RestaurantDetailViewModel
    
    var dataSource: UICollectionViewDiffableDataSource<Section, AnyHashable>!
    var wishListBarButton = UIBarButtonItem()
    
    init(viewModel: RestaurantDetailViewModel) {
        self.viewModel = viewModel
        super.init(collectionViewLayout: RestaurantDetailVC.createCollectionViewLayout())
    }
    
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        
        var insets = view.safeAreaInsets
        insets.top = 0
        collectionView.contentInset = insets
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        configureNavigationBar()
        configureViewModel()
        configureCollectionView()
        configureDataSource()
        setupHeader()
    }
    
    func configureViewModel() {
        viewModel.photoEntriesChangedHandler = updatePhotoEntries
        viewModel.isWishListedChangedHandler = updateWishListButton
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
        viewModel.fetchPhotoEntries()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func configureNavigationBar() {
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationItem.title = ""
        
        let addPhotoEntryBarButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddImageButtonTapped))
        addPhotoEntryBarButton.tintColor = .white
        
        wishListBarButton = UIBarButtonItem(image: .init(systemName: "star"), style: .plain, target: self, action: #selector(handleWishListButtonTapped))
        addPhotoEntryBarButton.tintColor = .white
        
        if viewModel.isWishListed {
            wishListBarButton.image = .init(systemName: "star.fill")
        }
        
        navigationItem.rightBarButtonItems = [addPhotoEntryBarButton, wishListBarButton]
    }
    
    func configureCollectionView() {
        collectionView.backgroundColor = .backgroundGray
        collectionView.delegate = self
        collectionView.register(RestaurantDetailHeaderCell.self, forCellWithReuseIdentifier: RestaurantDetailHeaderCell.reuseID)
        collectionView.register(PhotoEntryCell.self, forCellWithReuseIdentifier: PhotoEntryCell.reuseID)
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: SectionHeader.kind, withReuseIdentifier: SectionHeader.reuseID)
        collectionView.register(EmptyPhotoEntryCell.self, forCellWithReuseIdentifier: EmptyPhotoEntryCell.reuseID)
    }
    
    func configureDataSource() {
        self.dataSource = UICollectionViewDiffableDataSource<Section, AnyHashable>(collectionView: collectionView, cellProvider: { [weak self] collectionView, indexPath, item in
            guard let self = self else { fatalError("self is nil") }
            guard let section = Section(rawValue: indexPath.section) else { fatalError("unknown section") }
            
            switch section {
            case .header:
                guard let restaurant = item as? Business else { fatalError() }
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RestaurantDetailHeaderCell.reuseID, for: indexPath) as! RestaurantDetailHeaderCell
                cell.set(restaurant: restaurant)
                cell.delegate = self
                return cell
            case .photos:
                guard let wrappedEntry = item as? PhotoEntryWrapper else { fatalError() }
                let photoEntry = wrappedEntry.photoEntry
                
                if photoEntry.isEmpty {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyPhotoEntryCell.reuseID, for: indexPath) as! EmptyPhotoEntryCell
                    cell.addPhotoHandler = { self.handleAddImageButtonTapped() }
                    return cell
                } else {
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoEntryCell.reuseID, for: indexPath) as! PhotoEntryCell
                    cell.set(entry: photoEntry)
                    return cell
                }
            }
        })
        
        self.dataSource.supplementaryViewProvider = {collectionView, kind, indexPath in
            let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseID, for: indexPath) as! SectionHeader
            header.label.text = "Your Photos"
            return header
        }
    }
    
    func setupHeader() {
        var headerSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        headerSnapshot.append([viewModel.restaurant])
        self.dataSource.apply(headerSnapshot, to: .header, animatingDifferences: false)
    }
    
    func updatePhotoEntries(photoEntries: [PhotoEntryWrapper]) {
        var newPhotoEntries = photoEntries
        if newPhotoEntries.count == 0 {
            let emptyPhotoEntry = PhotoEntryWrapper(photoEntry: PhotoEntry(isEmpty: true))
            newPhotoEntries.append(emptyPhotoEntry)
        }
        
        var photoEntriesSnapshot = NSDiffableDataSourceSectionSnapshot<AnyHashable>()
        photoEntriesSnapshot.append(newPhotoEntries)
        dataSource.apply(photoEntriesSnapshot, to: .photos)
    }
    
    @objc func handleAddImageButtonTapped() {
        let addPhotoVC = UINavigationController(rootViewController: AddPhotoVC(restaurant: viewModel.restaurant))
        addPhotoVC.modalPresentationStyle = .fullScreen
        present(addPhotoVC, animated: true)
    }
    
    @objc func handleWishListButtonTapped() {
        viewModel.addOrRemoveFromWishList()
    }
    
    func updateWishListButton(isWishListed: Bool) {
        wishListBarButton.image = UIImage(systemName: isWishListed ? "star.fill" : "star")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Restore the navigation bar to default
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
    }
    
    static func createEmptyPhotosCollectionLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionNumber, env in
            guard let sectionKind = Section(rawValue: sectionNumber) else { return nil}
            
            if sectionKind == .header {
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(400)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                return section
            } else if sectionKind == .photos {
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalHeight(1.0)))
                
                let group = NSCollectionLayoutGroup.vertical(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .absolute(200)),
                    subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: SectionHeader.kind, alignment: .topLeading)]
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40)), elementKind: SectionHeader.kind, alignment: .topLeading, absoluteOffset: .init(x: 8 , y: 0))]
                
                return section
            }
            else {
                fatalError("unknown section")
            }
        }
    }
    
    static func createCollectionViewLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionNumber, env in
            guard let sectionKind = Section(rawValue: sectionNumber) else { return nil}
            
            switch sectionKind {
            case .header:
                let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)))
                
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(400)), subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                return section
            case .photos:
                let item = NSCollectionLayoutItem(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(0.5),
                        heightDimension: .fractionalWidth(0.5)))
                
                item.contentInsets = .init(top: 2, leading: 2, bottom: 2, trailing: 2)
                
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(
                        widthDimension: .fractionalWidth(1.0),
                        heightDimension: .fractionalWidth(0.5)),
                    subitems: [item])
                
                let section = NSCollectionLayoutSection(group: group)
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(50)), elementKind: SectionHeader.kind, alignment: .topLeading)]
                section.boundarySupplementaryItems = [.init(layoutSize: .init(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(40)), elementKind: SectionHeader.kind, alignment: .topLeading, absoluteOffset: .init(x: 8 , y: 0))]
                
                return section
            }
        }
    }
    
    func pushPhotoEntryDetailVC(index: Int) {
        let photoEntryDetailVC = PhotoEntryDetailVC(photoEntries: viewModel.photoEntries, entryIndex: index)
        navigationController?.pushViewController(photoEntryDetailVC, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let sectionKind = Section(rawValue: indexPath.section) else { fatalError("unknown section") }
        if sectionKind == .photos {
            if viewModel.photoEntries.isEmpty {
                return
            }
            pushPhotoEntryDetailVC(index: indexPath.item)
        }
    }
}

// TODO: use closure instead of delegation
extension RestaurantDetailVC: RestaurantDetailVCDelegate {
    func didTapOpenWithYelp() {
        guard let url = URL(string: viewModel.restaurant.url ?? "www.yelp.com") else {
            return
        }
        
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}

extension RestaurantDetailVC {
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let denom: CGFloat = 50
        let alpha = min(1, scrollView.contentOffset.y / denom)
        navigationController?.navigationBar.tintColor = .black.withAlphaComponent(alpha)
        navigationItem.rightBarButtonItem?.tintColor = .black.withAlphaComponent(alpha)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black.withAlphaComponent(alpha)]
        title = viewModel.restaurant.name
        if alpha <= 0.1 {
            navigationController?.navigationBar.tintColor = .white
            navigationItem.rightBarButtonItem?.tintColor = .white
        }
    }
}
