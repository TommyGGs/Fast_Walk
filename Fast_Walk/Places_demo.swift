//
//  Places_demo.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2023/12/19.
//

import Foundation
import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
//Google Places SDK Demo
class Places_demo : UIViewController {
    
    @IBOutlet private var nameLabel: UILabel!
    @IBOutlet private var addressLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    
    private var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
    }
    
    // Add a UIButton in Interface Builder, and connect the action to this function.
    
    @IBAction func press(_ sender: Any) {
        let placeFields: GMSPlaceField = [.name, .formattedAddress, .types, ]
        
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { [weak self] (placeLikelihoods, error) in
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Current place error: \(error?.localizedDescription ?? "")")
                return
            }
            guard let place = placeLikelihoods?[2].place else {
                strongSelf.nameLabel.text = "No current place"
                strongSelf.addressLabel.text = ""
                return
            }
//            if let likelihoods = placeLikelihoods?.prefix(3) { // Get the first three places
//                for likelihood in likelihoods {
//                    let place = likelihood.place
//                    strongSelf.addMarker(place: place)
//                }
//            }
            
            
            dump(placeLikelihoods)
            
            strongSelf.ratingLabel.text = place.types?.joined(separator: ",\n")
            
            strongSelf.nameLabel.text = place.name
            strongSelf.addressLabel.text = place.formattedAddress
        }
        
        
    }
//    private func addMarker(place: GMSPlace) {
//        guard let mapView = mapView else { return }
//        let marker = GMSMarker()
//        marker.position = place.coordinate
//        marker.title = place.name
//        marker.snippet = place.formattedAddress
//        marker.map = mapView
//    }
    
    // Add a pair of UILabels in Interface Builder, and connect the outlets to these variables.
    
}
