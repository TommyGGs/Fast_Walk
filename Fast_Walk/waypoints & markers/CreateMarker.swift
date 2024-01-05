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
    
    var placesClient: GMSPlacesClient!

    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        print ("view did load")
    }
    
    
    
    func addMarker(_ place: GMSPlace, _ mapView: GMSMapView?) {
        let marker = GMSMarker()
        marker.position = place.coordinate
        marker.title = place.name
        marker.snippet = place.types?.joined(separator: ",\n")
        marker.map = mapView
        
        createPhoto(place.placeID!) { placePhoto in
            if let placePhoto = placePhoto {
                DispatchQueue.main.async {
                    marker.icon = placePhoto
                }
                print("marker loaded")
            }
        }
    }

    func createPhoto(_ placeid: String, completion: @escaping (UIImage?) -> Void) {
        let fields: GMSPlaceField = [.photos]
        
        guard let placesClient = self.placesClient else {
                print("PlacesClient is nil")
                completion(nil)
                return
            }
        
        placesClient.fetchPlace(fromPlaceID: placeid, placeFields: fields, sessionToken: nil, callback: {
            (place: GMSPlace?, error: Error?) in
            if let error = error {
                print("An error occurred: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let place = place, let photoMetadata = place.photos?.first {
                print (photoMetadata)
                self.loadPhoto(photoMetadata, completion: completion)
            }
        })
    }

    func loadPhoto(_ metadata: GMSPlacePhotoMetadata, completion: @escaping (UIImage?) -> Void) {
        placesClient.loadPlacePhoto(metadata, callback: { (photo, error) in
            if let error = error {
                print("Error loading photo metadata: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let photo = photo {
                completion(photo)
            }
        })
    }

}


