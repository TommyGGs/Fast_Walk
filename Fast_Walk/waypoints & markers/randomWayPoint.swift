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
    
    private var placesClient: GMSPlacesClient!
    private var nextCoordinate: CLLocationCoordinate2D?
    private let wayPointNumber = 3
    
    init() {
        placesClient = GMSPlacesClient.shared()
    }
    
    func findRoute(_ coordinate: CLLocationCoordinate2D, desiredTime: Int, completion: @escaping ([GMSPlace?]) -> Void) {
        let radius = calculateRadiusBasedOnTime(desiredTime)
        performNearbySearch(from: coordinate, radius: radius, type: "restaurant") { places in
            let shuffledPlaces = places.shuffled() // Shuffle the places to randomize them
            let placeInfos = Array(shuffledPlaces.prefix(self.wayPointNumber)) //change here when increasing number of waypoint results
            completion (placeInfos)
        }
    }
    
    

    
    private func performNearbySearch(from coordinate: CLLocationCoordinate2D, radius: Double, type: String, completion: @escaping ([GMSPlace?]) -> Void) {
        print ("called performNearbySearch")
        //let radius: Double = 1000 // Search within 1000 meters of the coordinate
        let type = "restaurant" // Specify the type of place you are looking for
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)" + "&type=\(type)&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"
        
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
                
                for result in results.prefix(7) {//change here when increasing number of results
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
        //CONTINUE:: placesClient.
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
    
    private func calculateRadiusBasedOnTime(_ desiredTime: Int) -> Double {
        // Adjust the radius based on desired time
        switch desiredTime {
        case 30: return 750 // Example radius for 30 minutes
        case 45: return 1000 // Example radius for 45 minutes
        case 60, 90: return 1500 // Example radius for 60 or 90 minutes
        default: return 500
        }
    }
}

