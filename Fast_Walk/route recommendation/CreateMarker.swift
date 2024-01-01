//
//  CreateMarker.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2023/12/22.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class Marker: UIViewController {
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    
    func addMarker(_ place: GMSPlace, _ mapView: GMSMapView?) {
        /* guard let mapView = mapView else {
            return } */
        print("marker loaded")
        let marker = GMSMarker()
        marker.position = place.coordinate
        marker.title = place.name
        marker.snippet = place.types?.joined(separator: ",\n")
        marker.map = mapView
        marker.icon = GMSMarker.markerImage(with: .black)
        
    }
}

