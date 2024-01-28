import UIKit
import GoogleMaps
import GooglePlaces

class WayPointGeneration {
    
    private var placesClient: GMSPlacesClient
    private var nextCoordinate: CLLocationCoordinate2D?
    private var marker = Marker()
    
    init() {
        placesClient = GMSPlacesClient.shared()
    }
    
    func findRoute(_ waypoints: Int, completion: @escaping ([GMSPlace]) -> Void) {
        fetchLikelihoodList { currentLocation in
            if let currentLocation = currentLocation {
                let places: [GMSPlace] = [currentLocation]
                self.fetchNearbyPlaces(waypoints - 1, from: currentLocation.coordinate, places: places, completion: completion)
            } else {
                completion([])
            }
        }
    }
    
    private func fetchNearbyPlaces(_ waypointsRemaining: Int, from coordinate: CLLocationCoordinate2D, places: [GMSPlace], completion: @escaping ([GMSPlace]) -> Void) {
        if waypointsRemaining == 0 {
            completion(places)
            return
        }
        
        performNearbySearch(from: coordinate) { newPlace in
            if let newPlace = newPlace {
                var updatedPlaces = places
                updatedPlaces.append(newPlace)
                self.fetchNearbyPlaces(waypointsRemaining - 1, from: newPlace.coordinate, places: updatedPlaces, completion: completion)
                print(newPlace.name)
            } else {
                completion(places)
            }
        }
    }
    
    private func fetchLikelihoodList(completion: @escaping (GMSPlace?) -> Void) {
        let placeFields: GMSPlaceField = [.name, .formattedAddress, .placeID, .coordinate, .types]
        placesClient.findPlaceLikelihoodsFromCurrentLocation(withPlaceFields: placeFields) { (placeLikelihoods, error) in
            if let error = error {
                print("Current place error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            let currentPlace = placeLikelihoods?.first?.place
            completion(currentPlace)
        }
    }
    
    private func performNearbySearch(from coordinate: CLLocationCoordinate2D, completion: @escaping (GMSPlace?) -> Void) {
        let radius: Double = 200 // Search within 1000 meters of the coordinate
        let type = "restaurant" // Specify the type of place you are looking for
        
        let urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&type=\(type)&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion(nil)
                return
            }
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                guard let json = jsonObject as? [String: Any],
                      let results = json["results"] as? [[String: Any]],
                      !results.isEmpty else {
                    print("No results found")
                    completion(nil)
                    return
                }
                //add filter algorithm to find top rating and needed categories
                let firstResult = results[0]
                if let placeID = firstResult["place_id"] as? String {
                    self?.fetchPlaceDetails(placeID: placeID, completion: completion)
                } else {
                    print("No valid place ID found")
                    completion(nil)
                }
            } catch {
                print("JSON parsing error: \(error)")
                completion(nil)
            }
        }.resume()
    }
    
    private func fetchPlaceDetails(placeID: String, completion: @escaping (GMSPlace?) -> Void) {
        placesClient.lookUpPlaceID(placeID) { (place, error) in
            if let error = error {
                print("Error fetching place details: \(error.localizedDescription)")
                completion(nil)
                return
            }
            completion(place)
        }
    }
}
