//
//  manualWayPoint.swift
//  Fast_Walk
//
//  Created by Jianjun Zhao on 2023/12/25.
//

import Foundation
import UIKit
import GoogleMaps
import GooglePlaces

class randomWayPoint {
    
    private var placesClient: GMSPlacesClient
    private var nextCoordinate: CLLocationCoordinate2D?
    private var marker = Marker()
    
    init() {
        placesClient = GMSPlacesClient.shared()
    }
    
    
    func findRoute(_ waypoints: Int, _ coordinate: CLLocationCoordinate2D, completion: @escaping ([GMSPlace?]) -> Void) {
        performNearbySearch(from: coordinate) { wayPoints in
            for wayPoint in wayPoints {
                if let wayPoint = wayPoint {
                    print (wayPoint.name)
                }
                else{
                    print ("findRoute failed")
                }
            }
            var truncatedwayPoints = Array(wayPoints.prefix(waypoints))
            completion (truncatedwayPoints)
        }
    }
    
//    private func fetchLikelihoodList(completion: @escaping (GMSPlace?) ->Void ) {
//        
//        let placeFields: GMSPlaceField = [.name, .placeID]
//        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { (placeLikelihoods, error) in
//            if let error = error {
//                print("Current place error: \(error.localizedDescription)")
//                return
//            }
//            completion(placeLikelihoods?[0].place)
//        }
//    }
    
    private func performNearbySearch(from coordinate: CLLocationCoordinate2D, completion: @escaping ([GMSPlace?]) -> Void) {
        print ("called performNearbySearch")
        let radius: Double = 1000 // Search within 1000 meters of the coordinate
        let type = "point_of_interest" // Specify the type of place you are looking for
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&type=\(type)&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion([])
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion([])
                return
            }
            print ("no network error")
            guard let data = data else {
                print("No data received")
                completion([])
                return
            }
            
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let json = jsonObject as? [String: Any],
                      let results = json["results"] as? [[String: Any]],
                      !results.isEmpty else {
                    print("No results found")
                    completion([])
                    return
                }
                
                let dispatchGroup = DispatchGroup()
                var wayPoints: [GMSPlace?] = []
                
                for result in results {
                    if let placeID = result["place_id"] as? String {
                        dispatchGroup.enter() // Enter the group
                        self?.fetchPlaceDetails(placeID: placeID) { placeDetail in
                            wayPoints.append(placeDetail)
                            dispatchGroup.leave() // Leave the group
                        }
                    }
                }
                
                dispatchGroup.notify(queue: DispatchQueue.main) {
                    print("All place details fetched.")
                    completion(wayPoints)
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion([])
            }
        }.resume()
    }
    
    
    private func fetchPlaceDetails(placeID: String, completion: @escaping (GMSPlace?) -> Void) {
        print ("called fetchPlaceDetails")
        placesClient.lookUpPlaceID(placeID) { (place, error) in
            if let error = error {
                print("Error fetching place details: \(error.localizedDescription)")
                completion(nil)
                return
            }
            //print(place)
            completion(place)
        }
    }
}
