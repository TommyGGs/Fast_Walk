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
    private var wayPointNumber: Int! = 3
    
    
    init() {
        placesClient = GMSPlacesClient.shared()
    }
    
    func findRoute(_ coordinate: CLLocationCoordinate2D, desiredTime: Int, types: String, mode: String, completion: @escaping ([GMSPlace?]) -> Void) {
        if mode == "Route"{
            wayPointNumber = 1
            print("mode: Route")
        }
        print("type:", types)
        let radius = calculateRadiusBasedOnTime(desiredTime)
        performNearbySearch(from: coordinate, radius: radius, type: types) { places in
            let shuffledPlaces = places.shuffled() // Shuffle the places to 
            print("places array:", places, shuffledPlaces)
            //            let placeInfos = Array(shuffledPlaces.prefix(self.wayPointNumber))
            let placeInfos = Array(shuffledPlaces.prefix(self.wayPointNumber))

            completion (placeInfos)
        }
    }
    
    

    
    private func performNearbySearch(from coordinate: CLLocationCoordinate2D, radius: Double, type: String, completion: @escaping ([GMSPlace?]) -> Void) {
        
        let optionNumber = 9 //change here when increasing number of results
        
        print ("called performNearbySearch")
//        let radius: Double = 30 // Search within 1000 meters of the coordinate
        let apiKey = "&key=\(APIKeys.shared.GMSServices)"
        var typeOrNot = "&type=\(type)"
//        if type == "" {
//            print("type is blank")
//            typeOrNot = ""
//        }
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)" + typeOrNot + apiKey
        print("url:", urlString)
        
        
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
                
                
                
                for result in results.prefix(optionNumber) {
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
    
    private func calculateRadiusBasedOnTime(_ desiredTime: Int) -> Double {
        switch desiredTime {
        case 10: print("case 10"); return 300
        case 20: print("case 20"); return 700
        case 30: print("case 30"); return 700 // Example radius for 30 minutes
        case 45: return 750 // Example radius for 45 minutes
        case 60, 90: return 1000 // Example radius for 60 or 90 minutes
        default: return 500
        }
    }
}

