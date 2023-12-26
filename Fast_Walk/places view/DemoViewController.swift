//
//  DemoViewController.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2023/12/26.
//

import Foundation
import UIKit
import GoogleMaps

class DemoViewController: UIViewController, GMSMapViewDelegate {

    var mapView: GMSMapView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Set initial location to New York City
        let camera = GMSCameraPosition.camera(withLatitude: 40.7128, longitude: -74.0060, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: self.view.frame, camera: camera)
        mapView.delegate = self
        view.addSubview(mapView)

        // Add a marker
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060)
        marker.title = "New York City"
        marker.snippet = "The Big Apple"
        marker.map = mapView
    }

    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = CustomInfoWindow(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        infoWindow.titleLabel.text = marker.title
        return infoWindow
    }
}
