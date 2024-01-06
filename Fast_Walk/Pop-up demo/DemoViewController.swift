//
//  DemoViewController.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2023/12/26.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class DemoViewController: UIViewController, GMSMapViewDelegate {
    
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    @IBOutlet var mapContainerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        
        // Set initial location to New York City
        let camera = GMSCameraPosition.camera(withLatitude: 40.7128, longitude: -74.0060, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: self.mapContainerView.frame, camera: camera)
        mapView.delegate = self
        mapContainerView.addSubview(mapView)
        
        // Add a marker
        // Select the marker to trigger animation
        
    }
    @IBAction func press(){
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        marker.appearAnimation = .pop
        marker.title = "ニューヨーク"
        marker.snippet = "The Big Apple"
        marker.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = CustomInfoWindow()
        infoWindow.titleLabel.text = marker.title
        infoWindow.snippetLabel.text = marker.snippet
        infoWindow.pictureView.image = UIImage(named: "Liberty")
        infoWindow.frame = CGRect(x:0, y:0, width: 300, height: 200)
        
        return infoWindow
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        mapView.selectedMarker = marker
        
        if let title = marker.title {
            
            if let snippet = marker.snippet {
                print("marker title: \(title): snippet: \(snippet)")
            }
        }
        return true
    }
    
    
}
