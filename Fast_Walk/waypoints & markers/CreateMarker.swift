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

class Marker {
    
    var placesClient: GMSPlacesClient!

    
    init() {
        placesClient = GMSPlacesClient.shared()
    }
    
    
    
    func addMarker(_ place: GMSPlace, _ mapView: GMSMapView?) {
        let marker = GMSMarker()
        marker.position = place.coordinate
        if let name = place.name, let type = place.types?.first{
            marker.title = name
            marker.snippet = "評価：" + String(Int(place.rating)) + ", \(type)"
        }
        
        marker.map = mapView
        marker.appearAnimation = .pop
        //make photometadata
        loadPhoto(place.photos?.first) { placePhoto in
            if let placePhoto = placePhoto {
                DispatchQueue.main.async {
                    marker.userData = placePhoto
                }
                print("marker loaded")
            }
        }
    }

    func loadPhoto(_ metadata: GMSPlacePhotoMetadata?, completion: @escaping (UIImage?) -> Void) {
        guard let metadata = metadata else {
            print("photo metadata is nil")
            completion(nil)
            return
        }
        placesClient.loadPlacePhoto(metadata, callback: { (photo, error) in
            if let error = error {
                print("Error loading photo metadata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let photo = photo {
                print("photo metadata loaded")
                completion(photo)
            }
        })
    }

}


