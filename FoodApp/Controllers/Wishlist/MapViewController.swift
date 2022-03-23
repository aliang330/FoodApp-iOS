//
//  MapViewController.swift
//  FoodApp
//
//  Created by Allen Liang on 3/9/22.
// 

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    let reuseID = "annotation"
    
    var mapView: MKMapView
    var restaurants: [Business] = []
    
    init(restaurants: [Business]) {
        self.mapView = MKMapView()
        self.restaurants = restaurants
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        layoutSubViews()
    }
    
    func configureMap() {
        mapView.delegate = self
        
        if LocationManager.shared.isAuthorized {
            if let coordinate = LocationManager.shared.currentLocation?.coordinate {
                mapView.region = MKCoordinateRegion(center: .init(latitude: coordinate.latitude, longitude: coordinate.longitude), span: .init(latitudeDelta: 0.1, longitudeDelta: 0.1))
            }
        }
        
        restaurants.forEach {
            let annotation = MKPointAnnotation()
            annotation.title = $0.name
            annotation.coordinate = .init(latitude: $0.coordinates.latitude, longitude: $0.coordinates.longitude)
            mapView.addAnnotation(annotation)
        }
    }
    
    func layoutSubViews() {
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.constraintToViewBounds(view: self.view)
        
    }
}

extension MapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard annotation is MKPointAnnotation else { return nil}
//
//    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is MKPointAnnotation else { return nil }

        let identifier = "Annotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView!.canShowCallout = true
        } else {
            annotationView!.annotation = annotation
        }
        
        annotationView?.displayPriority = .required
        return annotationView
    }
}

