import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapContainerView: UIView!
    var locationManager = CLLocationManager()
    var mapView: GMSMapView?
    var currentLocation: CLLocationCoordinate2D?
    var bestRoute: [String: Any]?
    var bestDuration: Int = Int.max
    let semaphore = DispatchSemaphore(value: 0)

     override func viewDidLoad() {
         super.viewDidLoad()

         locationManager.delegate = self
         locationManager.requestWhenInUseAuthorization()

         let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 10.0)
         mapView = GMSMapView.map(withFrame: mapContainerView.bounds, camera: camera)

         if let mapView = mapView {
             mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
             mapContainerView.addSubview(mapView)
         }
     }

     func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         if status == .authorizedWhenInUse || status == .authorizedAlways {
             locationManager.startUpdatingLocation()
         }
     }

     func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
         if let location = locations.first, currentLocation == nil {
             currentLocation = location.coordinate

             if let mapView = mapView {
                 mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 10.0)
                 mapView.isMyLocationEnabled = true
                 mapView.settings.myLocationButton = true
             }

             locationManager.stopUpdatingLocation()
         }
     }
    func drawRandomRoute(from start: CLLocationCoordinate2D, attempt: Int = 1) {
        let waypoint1 = CLLocationCoordinate2D(latitude: start.latitude + randomCoordinateOffset(), longitude: start.longitude + randomCoordinateOffset())
        let waypoint2 = CLLocationCoordinate2D(latitude: start.latitude + randomCoordinateOffset(), longitude: start.longitude + randomCoordinateOffset())
        let waypoint3 = CLLocationCoordinate2D(latitude: start.latitude + randomCoordinateOffset(), longitude: start.longitude + randomCoordinateOffset())

        let waypoints = [waypoint1, waypoint2, waypoint3].map {
            "\($0.latitude),\($0.longitude)"
        }.joined(separator: "|")

        let origin = "\(start.latitude),\(start.longitude)"
        let encodedWaypoints = waypoints.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(origin)&waypoints=\(encodedWaypoints)&mode=walking&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                self?.semaphore.signal()
                return
            }

            guard let data = data else {
                print("No data received")
                self?.semaphore.signal()
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                print("API Response: \(json)") // Debugging

                if let routes = json["routes"] as? [Any], !routes.isEmpty,
                   let route = routes[0] as? [String: Any],
                   let legs = route["legs"] as? [[String: AnyObject]],
                   let distance = legs.first?["distance"] as? [String: AnyObject],
                   let distanceValue = distance["value"] as? Int {
                    
                    let adjustedDuration = (Double(distanceValue) / 1000.0) / 5.0 * 3600 // Time in seconds
                    let durationMinutes = Int(adjustedDuration) / 60 // Convert to minutes

                    if durationMinutes >= 25 && durationMinutes <= 35 {
                        if durationMinutes < self?.bestDuration ?? Int.max {
                            self?.bestRoute = route
                            self?.bestDuration = durationMinutes
                        }
                    }
                } else {
                    print("No suitable route found or invalid response.")
                }
            } catch let error {
                print("JSON parsing error: \(error.localizedDescription)")
            }

            if attempt < 10 {
                self?.drawRandomRoute(from: start, attempt: attempt + 1)
            } else if let bestRoute = self?.bestRoute {
                self?.displayRouteOnMap(route: bestRoute, start: start, durationText: "\(self?.bestDuration ?? 0) min")
            } else {
                print("No suitable route found.")
            }
            self?.semaphore.signal()
        }.resume()

        semaphore.wait()
    }

    func displayRouteOnMap(route: [String: Any], start: CLLocationCoordinate2D, durationText: String) {
        DispatchQueue.main.async {
            if let overviewPolyline = route["overview_polyline"] as? [String: Any],
               let polyString = overviewPolyline["points"] as? String,
               let path = GMSPath(fromEncodedPath: polyString), let mapView = self.mapView {

                let polyline = GMSPolyline(path: path)
                polyline.strokeWidth = 5.0
                polyline.strokeColor = UIColor.systemBlue
                polyline.map = mapView

                let bounds = GMSCoordinateBounds(path: path)
                let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
                mapView.animate(with: update)

                let durationMarker = GMSMarker(position: start)
                durationMarker.title = "Estimated Walking Time"
                durationMarker.snippet = durationText
                durationMarker.map = mapView
                mapView.selectedMarker = durationMarker
            } else {
                print("Failed to draw the route on the map.")
            }
        }
    }

    func randomCoordinateOffset() -> Double {
        return Double.random(in: -0.02...0.02)
    }
}
