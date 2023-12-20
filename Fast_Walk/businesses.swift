////
////  businesses.swift
////  Fast_Walk
////
////  Created by Jianjun Zhao on 2023/12/20.
////
//
//import Foundation
//import GoogleMaps
//import GooglePlaces
//
//class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
//    @IBOutlet weak var mapView: GMSMapView!
//    private var locationManager = CLLocationManager()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        // Initialize and configure the map view
//        mapView.delegate = self
//        mapView.isMyLocationEnabled = true
//
//        // Initialize the location manager
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyBest
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            // Center the map on the user's current location
//            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15)
//
//            // Fetch nearby businesses using the Google Places API
//            let placesClient = GMSPlacesClient.shared()
//            let filter = GMSAutocompleteFilter()
//            //filter.types = .establishment  // You can customize this based on your needs
//
//            placesClient.currentPlace { (placeLikelihoods, error) in
//                if let error = error {
//                    print("Error fetching nearby places: \(error.localizedDescription)")
//                    return
//                }
//
//                if let likelihood = placeLikelihoods?[0] {
//                    // Loop through nearby places and add pins to the map
//                    for place in likelihood.likelihoods {
//                        let placeID = place.place.placeID
//                        placesClient.lookUpPlaceID(placeID) { (place, error) in
//                            if let error = error {
//                                print("Error fetching place details: \(error.localizedDescription)")
//                                return
//                            }
//
//                            if let place = place {
//                                let marker = GMSMarker()
//                                marker.position = place.coordinate
//                                marker.title = place.name
//                                marker.map = self.mapView
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//}
