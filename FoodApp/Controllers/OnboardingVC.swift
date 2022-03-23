//
//  OnboardingVC.swift
//  FoodApp
//
//  Created by Allen Liang on 3/10/22.
//

import UIKit

class OnboardingVC: UIViewController {
    
    
    let locationIcon = UIImageView()
    let titleLabel = UILabel()
    let bodyLabel = UILabel()
    let imageView = UIImageView()
    let descriptionLabel = UILabel()
    let okButton = UIButton()
    
    let zipCodeTF = UITextField()
    let shareLocationButton = UIButton(type: .system)
    let errorLabel = ErrorLabel()
    let continueButton = UIButton()
    
    override func viewDidLoad() {
        view.backgroundColor = .white
        layoutView()
        setupNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tearDownNotifications()
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleStatusChanged), name: .init(rawValue: "locationAuthChanged"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func tearDownNotifications() {
        NotificationCenter.default.removeObserver(self, name: .init(rawValue: "locationAuthChanged"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let padding: CGFloat = 16
            continueButtonBottomContraint.isActive = false
            continueButtonBottomContraint = continueButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -(keyboardSize.height +  padding))
            continueButtonBottomContraint.isActive = true
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        let padding: CGFloat = -32
        self.continueButtonBottomContraint.constant = padding
    }
    
    @objc func handleStatusChanged() {
        switch LocationManager.shared.locationManager.authorizationStatus {
            
        case .notDetermined:
            break
        case .restricted:
            break
        case .denied:
            UIView.animate(withDuration: 0.2) {
                self.showZipCodeView()
            }
        case .authorizedAlways:
            break
        case .authorizedWhenInUse:
            presentTabBarController()
        @unknown default:
            break
        }
    }
    
    func presentTabBarController() {
        ProfileManager.onboardingComplete()
        let myTabBarController = TabBarController()
        myTabBarController.modalPresentationStyle = .fullScreen
        present(myTabBarController, animated: true)
    }
    
    
    func layoutView() {
        
        let views = [locationIcon, titleLabel, bodyLabel, imageView, descriptionLabel, okButton]
        
        views.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview($0)
        }
        
        locationIcon.image = UIImage(systemName: "location.fill")
        locationIcon.tintColor = .systemBlue
        locationIcon.contentMode = .scaleAspectFit
        
        titleLabel.textColor = .black
        titleLabel.font = .systemFont(ofSize: 26, weight: .bold)
        titleLabel.text = "Enable Location"
        
        bodyLabel.textColor = .black
        bodyLabel.font = .systemFont(ofSize: 14, weight: .regular)
        bodyLabel.text = "FoodApp works way better with location on."
        
        imageView.image = UIImage(named: "location")
        imageView.layer.cornerRadius = 30
        imageView.clipsToBounds = true
        
        descriptionLabel.textColor = .lightGray
        descriptionLabel.font = .systemFont(ofSize: 14, weight: .regular)
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 10
        descriptionLabel.text = "FoodApp receives your location when you're using the app to search for nearby restaurants, give you a better local experience, and more.\n\nYou can adjust your location settings at any time."
        
        okButton.backgroundColor = .yelpRed
        okButton.setTitleColor(.white, for: .normal)
        okButton.layer.cornerRadius = 4
        okButton.setTitle("OK, I understand", for: .normal)
        okButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        
        
        NSLayoutConstraint.activate([
            locationIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            locationIcon.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            locationIcon.widthAnchor.constraint(equalToConstant: 40),
            locationIcon.heightAnchor.constraint(equalToConstant: 40),
            
            titleLabel.topAnchor.constraint(equalTo: locationIcon.bottomAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: locationIcon.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            bodyLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            
            imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 300),
            
            descriptionLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
            descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: okButton.topAnchor, constant: -16),
            
            okButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            okButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            okButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            okButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    var continueButtonBottomContraint = NSLayoutConstraint()
    var errorLabelHeightContraint = NSLayoutConstraint()
    var shareLocationButtonTopContraint = NSLayoutConstraint()
    
    func showZipCodeView() {
        imageView.removeFromSuperview()
        descriptionLabel.removeFromSuperview()
        okButton.removeFromSuperview()
        
        view.addSubview(zipCodeTF)
        view.addSubview(errorLabel)
        view.addSubview(shareLocationButton)
        view.addSubview(continueButton)
        
        zipCodeTF.translatesAutoresizingMaskIntoConstraints = false
        shareLocationButton.translatesAutoresizingMaskIntoConstraints = false
        continueButton.translatesAutoresizingMaskIntoConstraints = false
        
        zipCodeTF.font = .systemFont(ofSize: 16)
        zipCodeTF.textColor = .black
        zipCodeTF.placeholder = "Enter a zip code"
        zipCodeTF.borderStyle = .roundedRect
        zipCodeTF.clearButtonMode = .whileEditing
        zipCodeTF.keyboardType = .numberPad
        zipCodeTF.delegate = self
        
        errorLabel.set(text: "You've entered an invalid zipcode")
        
        shareLocationButton.setTitle("Share location instead", for: .normal)
        shareLocationButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        shareLocationButton.sizeToFit()
        shareLocationButton.addTarget(self, action: #selector(shareLocationTapped), for: .touchUpInside)
        
        continueButton.setTitle("Continue", for: .normal)
        continueButton.setTitleColor(.lightGray, for: .normal)
        continueButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)

        continueButton.backgroundColor = .backgroundGray
        continueButton.layer.cornerRadius = 4
        continueButton.addTarget(self, action: #selector(continueButtonTapped), for: .touchUpInside)
        continueButton.isUserInteractionEnabled = false
        
        NSLayoutConstraint.activate([
            zipCodeTF.topAnchor.constraint(equalTo: bodyLabel.bottomAnchor, constant: 16),
            zipCodeTF.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            zipCodeTF.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            zipCodeTF.heightAnchor.constraint(equalToConstant: 44),
            
            errorLabel.topAnchor.constraint(equalTo: zipCodeTF.bottomAnchor, constant: 8),
            errorLabel.leadingAnchor.constraint(equalTo: zipCodeTF.leadingAnchor),
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            shareLocationButton.leadingAnchor.constraint(equalTo: zipCodeTF.leadingAnchor),
            
            continueButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            continueButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            continueButton.heightAnchor.constraint(equalToConstant: 44),
        ])
        
        errorLabelHeightContraint = errorLabel.heightAnchor.constraint(equalToConstant: 0)
        errorLabelHeightContraint.isActive = true
        
        shareLocationButtonTopContraint = shareLocationButton.topAnchor.constraint(equalTo: zipCodeTF.bottomAnchor, constant: 16)
        shareLocationButtonTopContraint.isActive = true
        
        continueButtonBottomContraint = continueButton.bottomAnchor.constraint(equalTo:  view.safeAreaLayoutGuide.bottomAnchor, constant: -32)
        continueButtonBottomContraint.isActive = true
        
        zipCodeTF.becomeFirstResponder()
    }
    
    @objc func okButtonTapped() {
        LocationManager.shared.requestAuthorization()
    }
    
    @objc func shareLocationTapped() {
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
    

    
    @objc func continueButtonTapped() {
        guard let zipCode = zipCodeTF.text else { return }
        if !Validator.isValidZipCode(zipCode: zipCode){
            showErrorLabel(shouldShow: true)
            setContinueButtonActive(isActive: false)
            return
        }
        ProfileManager.setDefaultZipCode(zipCode: zipCode)
        presentTabBarController()
        
    }
    
    func showErrorLabel(shouldShow: Bool) {
            errorLabelHeightContraint.isActive = false
            errorLabelHeightContraint = self.errorLabel.heightAnchor.constraint(equalToConstant: shouldShow ? 20 : 0)
            errorLabelHeightContraint.isActive = true
            
            shareLocationButtonTopContraint.isActive = false
            shareLocationButtonTopContraint = shareLocationButton.topAnchor.constraint(equalTo: errorLabel.bottomAnchor, constant: shouldShow ? 8 : 16)
            shareLocationButtonTopContraint.isActive = true
        
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    func setContinueButtonActive(isActive: Bool) {
        continueButton.backgroundColor = isActive ? .yelpRed : .backgroundGray
        continueButton.setTitleColor(isActive ? .white : .lightGray, for: .normal)
        continueButton.isUserInteractionEnabled = isActive
    }
    
}

extension OnboardingVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let oldString = textField.text else { return true}
        let newString = oldString.replacingCharacters(in: Range(range, in: oldString)!, with: string)
        
        showErrorLabel(shouldShow: false)
        
        if newString.isEmpty {
            setContinueButtonActive(isActive: false)
        } else {
            setContinueButtonActive(isActive: true)
        }
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        setContinueButtonActive(isActive: false)
        showErrorLabel(shouldShow: false)
        return true
    }
}
