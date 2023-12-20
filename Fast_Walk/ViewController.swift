import UIKit
import GoogleMaps
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var mapContainerView: UIView!
    var locationManager = CLLocationManager()
    var mapView: GMSMapView?
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()

//force update location status and if so, begin updating location information. If not used, mapview may not load
        locationManager.delegate = self
            if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
                locationManager.startUpdatingLocation()
            } else {
                locationManager.requestAlwaysAuthorization()
            }

        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 10.0)
        mapView = GMSMapView.init(frame: mapContainerView.bounds, camera: camera)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapContainerView.addSubview(mapView!)
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

            //locationManager.stopUpdatingLocation()
            findBestRoute(from: location.coordinate)
        }
    }
    func findBestRoute(from start: CLLocationCoordinate2D) {
        var closestDuration = Int.max
        var bestRouteDetails: (polyString: String, durationText: String)?
        let group = DispatchGroup()

        for _ in 1...10 {
            group.enter()
            let waypoints = generateRandomWaypoints(from: start, count: 2)
            requestRoute(from: start, waypoints: waypoints) { polyString, duration in
                let durationInMinutes = duration / 60
                if abs(durationInMinutes - 30) < abs(closestDuration - 30) {
                    closestDuration = durationInMinutes
                    bestRouteDetails = (polyString, "\(durationInMinutes) min")
                }
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if let routeDetails = bestRouteDetails {
                self.displayRouteOnMap(polyString: routeDetails.polyString, start: start, durationText: routeDetails.durationText)
            }
        }
    }

    func generateRandomWaypoints(from start: CLLocationCoordinate2D, count: Int) -> [CLLocationCoordinate2D] {
        return (1...count).map { _ in
            CLLocationCoordinate2D(
                latitude: start.latitude + randomCoordinateOffset(),
                longitude: start.longitude + randomCoordinateOffset()
            )
        }
    }

    func requestRoute(from start: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D], completion: @escaping (String, Int) -> Void) {
        let waypointsString = waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
        let origin = "\(start.latitude),\(start.longitude)"
        let encodedWaypoints = waypointsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(origin)&waypoints=\(encodedWaypoints)&mode=walking&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"

        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion("", Int.max)
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion("", Int.max)
                return
            }

            guard let data = data else {
                print("No data received")
                completion("", Int.max)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]

                guard let routes = json["routes"] as? [Any], !routes.isEmpty,
                      let route = routes[0] as? [String: Any],
                      let overviewPolyline = route["overview_polyline"] as? [String: Any],
                      let polyString = overviewPolyline["points"] as? String,
                      let legs = route["legs"] as? [[String: AnyObject]] else {
                    completion("", Int.max)
                    return
                }

                let totalDurationSeconds = legs.compactMap { $0["duration"] as? [String: AnyObject] }.compactMap { $0["value"] as? Int }.reduce(0, +)
                completion(polyString, totalDurationSeconds)
            } catch {
                print("JSON parsing error")
                completion("", Int.max)
            }
        }.resume()
    }

    func displayRouteOnMap(polyString: String, start: CLLocationCoordinate2D, durationText: String) {
        if let path = GMSPath(fromEncodedPath: polyString), let mapView = self.mapView {
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.strokeColor = UIColor.systemBlue
            polyline.map = mapView

            let bounds = GMSCoordinateBounds(path: path)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapView.animate(with: update)

            let durationMarker = GMSMarker(position: start)
            durationMarker.title = "Route Start"
            durationMarker.snippet = "Estimated Total Walking Time: \(durationText)"
            durationMarker.map = mapView
            mapView.selectedMarker = durationMarker
        } else {
            print("Failed to draw the route on the map.")
        }
    }

    func randomCoordinateOffset() -> Double {
        return Double.random(in: -0.015...0.015)
    }
    

}

