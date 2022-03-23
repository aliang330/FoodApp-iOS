//
//  EditPhotoEntryVC.swift
//  FoodApp
//
//  Created by Allen Liang on 3/14/22.
//

import UIKit

class EditPhotoEntryVC: UIViewController {
    
    var photoEntry: PhotoEntry
    
    let foodImageView = UIImageView()
    let descriptionLabel = UILabel()
    let descriptionTF = UITextField()
    var completion: (String)->Void
    
    var descriptionTFFrame: CGRect = .zero
    
    init(photoEntry: PhotoEntry, completion: @escaping (String) -> Void) {
        self.photoEntry = photoEntry
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLayoutSubviews() {
        descriptionTFFrame = descriptionTF.frame
        descriptionTF.becomeFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupKeyboardNotifications()
        configureNavBar()
        layoutSubViews()
        createDismissKeyboardGesture()
    }
    
    deinit {
        tearDownNotifications()
    }
    
    func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func tearDownNotifications() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let keyboardHeight = keyboardSize.height
            let frameHeight = view.frame.height
            let descriptionBottomY = descriptionTFFrame.minY + descriptionTFFrame.height
            if keyboardHeight > (frameHeight - descriptionBottomY) {
                let padding: CGFloat = 16
                view.frame.origin.y = -(keyboardHeight - (frameHeight - descriptionBottomY) + padding)
            }
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        view.frame.origin.y = 0
    }
    
    func createDismissKeyboardGesture() {
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        view.addGestureRecognizer(tap)
    }
    
    func configureNavBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Edit Caption"
        
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissVC))
        navigationItem.leftBarButtonItem = cancelButton
        
        
        let postButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveChanges))
        navigationItem.rightBarButtonItem = postButton
        
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black]
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
    
    @objc func saveChanges() {
        guard let caption = descriptionTF.text else { return }
        PersistenceManager.saveChangesToPhotoEntry(photoEntry: photoEntry, newCaption: caption)
        completion(caption)
        dismissVC()
    }
    
    func layoutSubViews() {
        configureFoodImageView()

        view.addSubview(foodImageView)
        view.addSubview(descriptionLabel)
        view.addSubview(descriptionTF)
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionTF.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionLabel.text = "What's in this photo?"
        descriptionLabel.textColor = .black
        descriptionLabel.font = .systemFont(ofSize: 24, weight: .bold)
        
        descriptionTF.placeholder = "Example: Pad thai, pizza, steak tacos"
        descriptionTF.font = .systemFont(ofSize: 14)
        descriptionTF.textColor = .black
        descriptionTF.text = photoEntry.caption
        
        NSLayoutConstraint.activate([
            foodImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            foodImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            foodImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            foodImageView.heightAnchor.constraint(equalToConstant: 300),
            
            descriptionLabel.topAnchor.constraint(equalTo: foodImageView.bottomAnchor, constant: 16),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            descriptionLabel.heightAnchor.constraint(equalToConstant: 30),
            
            descriptionTF.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTF.leadingAnchor.constraint(equalTo: descriptionLabel.leadingAnchor),
            descriptionTF.trailingAnchor.constraint(equalTo: descriptionLabel.trailingAnchor),
            descriptionTF.heightAnchor.constraint(equalToConstant: 20)
        ])
        
        
    }
    
    func configureFoodImageView() {
        foodImageView.translatesAutoresizingMaskIntoConstraints = false
        foodImageView.contentMode = .scaleAspectFit
        foodImageView.backgroundColor = .backgroundGray
        foodImageView.image = PersistenceManager.loadUserImageFromFileSystem(path: photoEntry.imageUrl)
    }
    
}
