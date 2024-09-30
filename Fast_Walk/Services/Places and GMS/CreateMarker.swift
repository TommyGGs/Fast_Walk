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
    
    
    
//    func addMarker(_ place: GMSPlace, _ mapView: GMSMapView?, blue: Bool = false) {
//        let marker = GMSMarker()
//        marker.position = place.coordinate
//        if let name = place.name, let type = place.types?.first{
//            marker.title = name
//            marker.snippet = "評価：" + String(Int(place.rating)) + ", \(type)"
//        }
//        
//        if blue == true {
//            marker.icon = GMSMarker.markerImage(with: .blue)
//        }
//        marker.map = mapView
//        marker.appearAnimation = .pop
//        //make photometadata
//        loadPhoto(place.photos?.first) { placePhoto in
//            if let placePhoto = placePhoto {
//                DispatchQueue.main.async {
//                    marker.userData = placePhoto
//                }
//                print("marker loaded")
//            }
//        }
//    }
    
    
//    func addMarker(_ place: GMSPlace, _ mapView: GMSMapView?, blue: Bool = false) {
//        let marker = GMSMarker()
//        marker.position = place.coordinate
//
//        // Step 1: Fetch the name in Japanese using a URL request
//        let placeID = place.placeID ?? ""
//        let apiKey = "\(APIKeys.shared.GMSServices)" // Replace with your Google API Key
//        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&fields=name&language=ja&key=\(apiKey)"
//        
//        guard let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//        
//        let task = URLSession.shared.dataTask(with: url) { data, response, error in
//            if let error = error {
//                print("Error fetching place details: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let data = data else {
//                print("No data returned from the request")
//                return
//            }
//            
//            do {
//                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                   let result = json["result"] as? [String: Any],
//                   let nameInJapanese = result["name"] as? String {
//                    
//                    // Extract opening hours if available
//                    var openingHours = "営業時間情報なし"
//                    if let openingHoursDict = result["opening_hours"] as? [String: Any],
//                       let weekdayText = openingHoursDict["weekday_text"] as? [String] {
//                        openingHours = weekdayText.joined(separator: ", ")
//                    }
//                    
//                    // Update the marker with the Japanese name and other details
//                    DispatchQueue.main.async {
//                        marker.title = nameInJapanese
//
//                        if let type = place.types?.first {
//                            let typeTranslations: [String: String] = [
//                                "restaurant": "レストラン",
//                                "shopping": "ショッピング",
//                                "gourmet": "グルメ",
//                                "nature": "自然",
//                                "tourism": "観光"
//                            ]
//                            let typeInJapanese = typeTranslations[type] ?? type
//                            marker.snippet = "評価：" + String(Int(place.rating)) + ", ジャンル：" + typeInJapanese + ", 営業時間：" + openingHours
//                            print("here is marker snippet", marker.snippet)
//                        }
//
//                        if blue {
//                            marker.icon = GMSMarker.markerImage(with: .blue)
//                        }
//                        marker.map = mapView
//                        marker.appearAnimation = .pop
//                    }
//                }
//            } catch {
//                print("Error parsing JSON response: \(error.localizedDescription)")
//            }
//        }
//
//        task.resume()
//
////        let task = URLSession.shared.dataTask(with: url) { data, response, error in
////            if let error = error {
////                print("Error fetching place details: \(error.localizedDescription)")
////                return
////            }
////            
////            guard let data = data else {
////                print("No data returned from the request")
////                return
////            }
////            
////            do {
////                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
////                   let result = json["result"] as? [String: Any],
////                   let nameInJapanese = result["name"] as? String {
////                    
////                    // Step 2: Update the marker with the Japanese name and other details
////                    DispatchQueue.main.async {
////                        marker.title = nameInJapanese
////                        
////                        if let type = place.types?.first {
////                            let typeTranslations: [String: String] = [
////                                "restaurant": "レストラン",
////                                "shopping": "ショッピング",
////                                "gourmet": "グルメ",
////                                "nature": "自然",
////                                "tourism": "観光"
////                            ]
////                            
////                            let openingHours = place.openingHours?.weekdayText?.joined(separator: ", ") ?? "営業時間情報なし"
////                        
////                            
////                            let typeInJapanese = typeTranslations[type] ?? type
////                            marker.snippet = "評価：" + String(Int(place.rating)) + ", ジャンル：" + typeInJapanese
////                            print("here is marker snippet", marker.snippet)
////                        }
////
////                        if blue == true {
////                            marker.icon = GMSMarker.markerImage(with: .blue)
////                        }
////                        marker.map = mapView
////                        marker.appearAnimation = .pop
////                    }
////                }
////            } catch {
////                print("Error parsing JSON response: \(error.localizedDescription)")
////            }
////        }
////        
////        task.resume()
//
//        // Step 3: Load photo metadata (unchanged)
//        loadPhoto(place.photos?.first) { placePhoto in
//            if let placePhoto = placePhoto {
//                DispatchQueue.main.async {
//                    marker.userData = placePhoto
//                }
//                print("marker loaded")
//            }
//        }
//    }

    func addMarker(_ place: GMSPlace, _ mapView: GMSMapView?, blue: Bool = false) {
        let marker = GMSMarker()
        marker.position = place.coordinate

        // Step 1: Fetch the name and opening hours in Japanese using a URL request
        guard let placeID = place.placeID else {
            print("probably destination")
            let marker = GMSMarker()
            marker.title = "終着地点"
            marker.position = place.coordinate
            marker.map = mapView
            
            return
        }
        let apiKey = "\(APIKeys.shared.GMSServices)" // Replace with your Google API Key
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?placeid=\(placeID)&fields=name,opening_hours&language=ja&key=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
//            marker.icon = GMSMarker.markerImage(with: .blue)

            print("Invalid URL")
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching place details: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data returned from the request")
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let result = json["result"] as? [String: Any],
                   let nameInJapanese = result["name"] as? String {
                    
                    // Extract opening hours if available
                    var openingHours = "営業時間情報なし"
                    if let openingHoursDict = result["opening_hours"] as? [String: Any],
                       let weekdayText = openingHoursDict["weekday_text"] as? [String] {
                        
                        // Get the current day of the week and adjust the index
                        let calendar = Calendar(identifier: .gregorian)
                        let weekday = calendar.component(.weekday, from: Date()) // 1 = Sunday, 7 = Saturday
                        let weekdayIndex = (weekday + 5) % 7 // Adjust to 0 = Monday, 6 = Sunday
                        print("day of week", weekdayIndex)
                        
                        if weekdayText.indices.contains(weekdayIndex) {
                            openingHours = weekdayText[weekdayIndex]
                        } else {
                            print("Weekday index out of range")
                        }
                    }
                    
                    // Update the marker with the Japanese name and other details
                    DispatchQueue.main.async {
                        marker.title = nameInJapanese

                        if let type = place.types?.first {
                            let typeTranslations: [String: String] = [
                                "restaurant": "レストラン",
                                "shopping": "ショッピング",
                                "gourmet": "グルメ",
                                "nature": "自然",
                                "tourism": "観光"
                            ]
                            let typeInJapanese = typeTranslations[type] ?? type
                            marker.snippet = "評価：" + String(format: "%.1f", place.rating) + ", ジャンル：" + typeInJapanese + ", " + openingHours
                            print("Here is marker snippet:", marker.snippet ?? "No snippet")
                        }

                        if blue {
                            marker.icon = GMSMarker.markerImage(with: .blue)
                        }
                        marker.map = mapView
                        marker.appearAnimation = .pop
                    }
                }
            } catch {
                print("Error parsing JSON response: \(error.localizedDescription)")
            }
        }

        task.resume()

        // Load photo metadata (unchanged)
        loadPhoto(place.photos?.first) { placePhoto in
            if let placePhoto = placePhoto {
                DispatchQueue.main.async {
                    marker.userData = placePhoto
                }
                print("Marker loaded")
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


