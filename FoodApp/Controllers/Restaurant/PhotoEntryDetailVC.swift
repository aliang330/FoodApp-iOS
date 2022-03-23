//
//  PhotoEntryDetailVC.swift
//  FoodApp
//
//  Created by Allen Liang on 3/12/22.
//

import Foundation
import UIKit

class PhotoEntryDetailVC: UIViewController {
    enum Section {
        case main
    }
    
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, PhotoEntry>
    
    var photoEntries: [PhotoEntry]
    var entryIndex: Int {
        didSet {
            updateCaption()
        }
    }
    
    var collectionView: UICollectionView!
    var dataSource: DataSource!
    var scrolledToSelectedIndex = false
    let captionLabel = UILabel()
    let footerContainer = UIView()
    
    init(photoEntries: [PhotoEntryWrapper], entryIndex: Int) {
        self.photoEntries = photoEntries.map {$0.photoEntry}
        self.entryIndex = entryIndex
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureCollectionView()
        configureDataSource()
        updateDataSource()
        configureFooter()
    }
    
    func configureFooter() {
        footerContainer.addSubview(captionLabel)
        view.addSubview(footerContainer)
        
        captionLabel.translatesAutoresizingMaskIntoConstraints = false
        footerContainer.translatesAutoresizingMaskIntoConstraints = false
        
        footerContainer.backgroundColor = .black.withAlphaComponent(0.4)
        
        captionLabel.textColor = .white
        captionLabel.font = .systemFont(ofSize: 16, weight: .medium)
        captionLabel.numberOfLines = 5
        
        NSLayoutConstraint.activate([
            footerContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            footerContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerContainer.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/6),
            
            captionLabel.topAnchor.constraint(equalTo: footerContainer.topAnchor, constant: 16),
            captionLabel.leadingAnchor.constraint(equalTo: footerContainer.leadingAnchor, constant: 16),
            captionLabel.trailingAnchor.constraint(equalTo: footerContainer.trailingAnchor, constant: 16),
            captionLabel.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavBar()
        configureTabBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func configureNavBar() {
        let optionsButton = UIBarButtonItem(image: .init(systemName: "ellipsis"), style: .plain, target: self, action: #selector(showActionSheet))
        optionsButton.tintColor = .white
        navigationItem.rightBarButtonItem = optionsButton
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        backButton.tintColor = .white
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    @objc func popVC() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc func showActionSheet() {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(.init(title: "Edit Caption", style: .default, handler: { alert in
            //edit entry vc
            self.showEditPhotoEntryVC()
        }))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { alert in
            self.showDeleteConfirmationAlert()
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel))
        
        present(alert, animated: true)
    }
    
    func showEditPhotoEntryVC() {
        let photoEntry = photoEntries[entryIndex]
        let vc = EditPhotoEntryVC(photoEntry: photoEntry) { caption in
            self.photoEntries[self.entryIndex].caption = caption
            self.updateCaption()
        }
        
        let editPhotoEntryVC = UINavigationController(rootViewController: vc)
//        editPhotoEntryVC.modalPresentationStyle = .overFullScreen
        present(editPhotoEntryVC, animated: true)
    }
    
    func showDeleteConfirmationAlert() {
        let alert = UIAlertController(title: "Delete this Photo?", message: "Are you sure?", preferredStyle: .alert)
 
        alert.addAction(.init(title: "Cancel", style: .cancel))
        alert.addAction(.init(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.deletePhotoEntry()
        }))
        present(alert, animated: true)
    }
    
    func deletePhotoEntry() {
        guard photoEntries.count > entryIndex else { return }
        let photoEntry = photoEntries[entryIndex]
        PersistenceManager.deletePhotoEntry(photoEntry: photoEntry)
        photoEntries.remove(at: entryIndex)
        updateDataSource()
    }
    
    func configureTabBar() {
        tabBarController?.tabBar.isHidden = true
    }
    
    func scrollToSelectedIndex() {
        
    }
    
    func configureCollectionView() {
        let flowLayout = BetterSnappingLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.delegate = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .black
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.decelerationRate = .fast
        
        
        collectionView.register(PhotoEntryDetailCell.self, forCellWithReuseIdentifier: PhotoEntryDetailCell.reuseID)
        
        view.addSubview(collectionView)
        
        collectionView.constraintToViewBounds(view: view)
    }
    
    func configureDataSource() {
        self.dataSource = DataSource(collectionView: collectionView, cellProvider: { collectionView, indexPath, photoEntry in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoEntryDetailCell.reuseID, for: indexPath) as! PhotoEntryDetailCell
            cell.set(photoEntry: photoEntry)
            return cell
        })
    }

    func updateDataSource() {
        if photoEntries.count == 0 {
            navigationController?.popViewController(animated: true)
            return
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, PhotoEntry>()
        snapshot.appendSections([.main])
        snapshot.appendItems(photoEntries)
        DispatchQueue.main.async {
            self.dataSource.apply(snapshot)
            if !self.scrolledToSelectedIndex {
                let indexPath = IndexPath(item: self.entryIndex, section: 0)
                self.collectionView.scrollToItem(at: indexPath, at: [.centeredVertically, .centeredHorizontally], animated: false)
                self.scrolledToSelectedIndex = true
                self.updateCaption()
            }
            self.calculateCurrentIndex()
        }
    }
    
    func calculateCurrentIndex() {
        let offsetX = collectionView.contentOffset.x
        entryIndex = Int(offsetX / collectionView.bounds.width)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let itemWidth = collectionView.bounds.width
        guard itemWidth > 0 else { return }
        let offsetX = scrollView.contentOffset.x + (itemWidth/2)
        let index = Int(offsetX / itemWidth)
        entryIndex = index
    }
    
    func updateCaption() {
        let caption = photoEntries[entryIndex].caption
        captionLabel.text = caption
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension PhotoEntryDetailVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
}

class PhotoEntryDetailCell: UICollectionViewCell {
    static let reuseID = "photoEntryDetailCell"
    let imageView = ImageViewWithBlurredBackground(frame: .zero)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        addSubview(imageView)
        
        imageView.constraintToViewBounds(view: self)
    }
    
    func set(photoEntry: PhotoEntry) {
        let image = PersistenceManager.loadUserImageFromFileSystem(path: photoEntry.imageUrl)
        DispatchQueue.main.async {
            self.imageView.set(image: image)
        }
    }
}

class ImageViewWithBlurredBackground: UIView {
    let backgroundImage = UIImageView()
    let image = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        image.translatesAutoresizingMaskIntoConstraints = false
        let blurEffect = UIBlurEffect(style: .dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        
        addSubview(backgroundImage)
        backgroundImage.addSubview(blurEffectView)
        addSubview(image)
        
        
        backgroundImage.backgroundColor = .black
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.clipsToBounds = true
        
        image.backgroundColor = .clear
        image.contentMode = .scaleAspectFit
        
        backgroundImage.constraintToViewBounds(view: self)
        blurEffectView.constraintToViewBounds(view: backgroundImage)
        image.constraintToViewBounds(view: self)
        
    }
    
    func set(image: UIImage?) {
        backgroundImage.image = image
        self.image.image = image
    }
}

class BetterSnappingLayout: UICollectionViewFlowLayout {
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        guard let collectionView = collectionView else {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        let nextX: CGFloat
        if proposedContentOffset.x <= 0 || collectionView.contentOffset == proposedContentOffset {
            nextX = proposedContentOffset.x
        } else {
            nextX = collectionView.contentOffset.x + (velocity.x > 0 ? collectionView.bounds.size.width : -collectionView.bounds.size.width)
        }
        
        let targetRect = CGRect(x: nextX, y: 0, width: collectionView.bounds.size.width, height: collectionView.bounds.size.height)
        
        var offsetAdjustment = CGFloat.greatestFiniteMagnitude
        
        let horizontalOffset = proposedContentOffset.x + collectionView.contentInset.left

        let layoutAttributesArray = super.layoutAttributesForElements(in: targetRect)
        
        layoutAttributesArray?.forEach({ (layoutAttributes) in
            let itemOffset = layoutAttributes.frame.origin.x
            if fabsf(Float(itemOffset - horizontalOffset)) < fabsf(Float(offsetAdjustment)) {
                offsetAdjustment = itemOffset - horizontalOffset
            }
        })
        let itemWidth = collectionView.bounds.size.width
        offsetAdjustment =  offsetAdjustment.truncatingRemainder(dividingBy: itemWidth)
        return CGPoint(x: proposedContentOffset.x + offsetAdjustment, y: proposedContentOffset.y)
    }
    
}
