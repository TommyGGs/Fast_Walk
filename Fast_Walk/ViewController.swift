import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import GoogleSignIn
import LineSDK

class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var profilePic: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var button30: UIButton!
    @IBOutlet weak var button45: UIButton!
    @IBOutlet weak var button60: UIButton!
    @IBOutlet weak var button90: UIButton!
    @IBOutlet weak var startButton: UIButton!
    var locationManager = CLLocationManager()
    var mapView: GMSMapView? //static throughout scope of entire program
    var currentLocation: CLLocationCoordinate2D?
    var selectedRouteDetails: RouteDetails?
    var currentRoutePolyline: GMSPolyline?
    var storedRouteDetails: RouteDetails?
    var marker = Marker()
    var wayPointGeneration = WayPointGeneration()
    var randomwaypoint: randomWayPoint!
    var window: UIWindow?
    
    
    private var placesClient: GMSPlacesClient! //For Places marker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared() //Places
        randomwaypoint = randomWayPoint()
        locationManager.delegate = self
        beginLocationUpdate()
        setupMapView()
        fetchGoogleUserInfo()
        fetchLineUserInfo()
        setupStyle()
        print("passed")
        let navView = UIView()
        navView.backgroundColor = UIColor.lightGray
        navView.layer.cornerRadius = 2
        view.addSubview(navView)

        // Create a heart button
        let heartButton = UIButton(type: .system)
        let heartSize: CGFloat = 30  // Set the size of the heart button
        let buttonX = navView.bounds.width - heartSize - 10
        let buttonY: CGFloat = 10
        let buttonFrame = CGRect(x: buttonX, y: buttonY, width: heartSize, height: heartSize)
        heartButton.frame = buttonFrame
        heartButton.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        navView.addSubview(heartButton)

        // Send navView to the back
        view.sendSubviewToBack(navView)
    }
    
    
    func setupMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: mapContainerView.bounds, camera: camera)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView?.delegate = self // Set the delegate after initializing the mapView
        
        mapContainerView.addSubview(mapView!)
        beginLocationUpdate()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        beginLocationUpdate()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first, currentLocation == nil {
            currentLocation = location.coordinate
            updateMapCamera(location.coordinate)
            mapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: 10.0)
            mapView?.isMyLocationEnabled = true
            mapView?.settings.myLocationButton = true
            mapView?.settings.zoomGestures = true //allows for zoom
            locationManager.stopUpdatingLocation() //why is this here? stop updating location
        }
    }
    
    func beginLocationUpdate() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func updateMapCamera(_ coordinate: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 10.0)
        mapView?.animate(with: cameraUpdate)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
    }
    
    func calculateWaypointAdjustment(for desiredTime: Int) -> Double {
        // Adjust this logic as needed for your app
        switch desiredTime {
        case 30:
            return 0.005 // Smaller range for shorter routes
        case 45:
            return 0.010 // Medium range
        case 60, 90:
            return 0.015 // Larger range for longer routes
        default:
            return 0.005 // Default range
        }
    }
    
    @IBAction func useRoute() {
        if storedRouteDetails != nil {
            performSegue(withIdentifier: "showRoute", sender: self)
        } else {
            print("No route available to use")
        }
    }
    
    
    
    @IBAction func searchRoute(_ sender: UIButton) {
        print("Search button pressed")
        currentRoutePolyline?.map = nil
        currentRoutePolyline = nil
        mapView?.clear()
        if var currentLocation = self.currentLocation,
           let buttonText = sender.titleLabel?.text,
           let desiredTime = Int(buttonText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
            print("Current location is available: \(currentLocation)")
            print("Desired time: \(desiredTime)")
            findBestRoute(from: currentLocation, desiredTime: desiredTime)
        } else {
            print("Current location is not available or invalid route time.")
        }
    }
    
    func findBestRoute(from start: CLLocationCoordinate2D, desiredTime: Int) {
        var closestDuration = Int.max
        var bestRouteDetails: (polyString: String, durationText: String)?
        let group = DispatchGroup()
        //
        //        for _ in 1...2 {
        group.enter()
        randomwaypoint.findRoute(start, desiredTime: desiredTime) { placeInfos in
            for placeInfo in placeInfos {
                if let placeInfo = placeInfo{
                    DispatchQueue.main.async{
                        self.marker.addMarker(placeInfo, self.mapView)
                    }
                }
                
                //                let waypointMarker = GMSMarker()
                //                waypointMarker.position = placeInfo!.coordinate
                //                waypointMarker.title = placeInfo!.name
                //                waypointMarker.map = self.mapView
                //                waypointMarker.icon = GMSMarker.markerImage(with: .blue)
            }
            self.requestRoute(from: start, waypoints: placeInfos.map(\.!.coordinate)) { polyString, duration in
                let durationInMinutes = duration / 60
                if abs(durationInMinutes - desiredTime) < abs(closestDuration - desiredTime) {
                    closestDuration = durationInMinutes
                    bestRouteDetails = (polyString, "\(durationInMinutes) 分")
                }
                
                group.leave()
            }
        }
        
        
        
        
        //        }
        
        group.notify(queue: .main) {
            if let routeDetails = bestRouteDetails {
                self.storedRouteDetails = RouteDetails(
                    polyString: routeDetails.polyString,
                    durationText: routeDetails.durationText,
                    startCoordinate: start
                )
                
                // Update the map with the newly found route
                self.displayRouteOnMap(polyString: routeDetails.polyString, start: start, durationText: routeDetails.durationText)
            } else {
                print("No best route found, displaying the first route anyway.")
                
                // Generate random waypoints for the first route
                let firstWaypoints = self.generateRandomWaypoints(from: start, count: 2, adjustment: self.calculateWaypointAdjustment(for: desiredTime))
                
                // Check if firstWaypoints is not nil before using it
                if !firstWaypoints.isEmpty {
                    self.requestRoute(from: start, waypoints: firstWaypoints) { polyString, duration in
                        self.displayRouteOnMap(polyString: polyString, start: start, durationText: "\(duration / 60) min")
                    }
                } else {
                    print("Failed to generate random waypoints for the first route.")
                }
            }
        }
    }
    
    
    
    
    func generateRandomWaypoints(from start: CLLocationCoordinate2D, count: Int, adjustment: Double) -> [CLLocationCoordinate2D] {
        return (1...count).map { _ in
            CLLocationCoordinate2D(latitude: start.latitude + Double.random(in: -adjustment...adjustment),
                                   longitude: start.longitude + Double.random(in: -adjustment...adjustment))
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
        if let path = GMSPath(fromEncodedPath: polyString) {
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.strokeColor = UIColor.systemBlue
            polyline.map = mapView
            
            self.currentRoutePolyline = polyline
            
            let bounds = GMSCoordinateBounds(path: path)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapView?.animate(with: update)
            
            let durationMarker = GMSMarker(position: start)
            durationMarker.title = "開始地点"
            durationMarker.snippet = "予測時間: \(durationText)"
            durationMarker.map = mapView
            mapView?.selectedMarker = durationMarker
        } else {
            print("Failed to draw the route on the map.")
        }
    }
    
    func randomCoordinateOffset() -> Double {
        return Double.random(in: -0.005...0.005)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoute", let destinationVC = segue.destination as? RouteViewController {
            destinationVC.routeDetails = storedRouteDetails
        }
    }
    
    @IBAction func signOut(sender: Any) {
        
        GIDSignIn.sharedInstance.signOut()
        LoginManager.shared.logout { result in
            switch result {
            case .success:
                print("Logout from LINE")
            case .failure(let error):
                print(error)
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen  // Ensuring it covers the full screen
        self.present(loginVC, animated: true, completion: nil)
    }
    
    func fetchGoogleUserInfo() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            // User is already signed in; proceed to fetch profile information
            updateProfileInfo(user: user)
        } else {
            print("User is not signed in.")
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            self.window?.rootViewController = loginVC
        }
    }
    
    
    func fetchLineUserInfo() {
        API.getProfile { result in
            switch result {
            case .success(let profile):
                if let url = profile.pictureURL {
                    self.downloadImage(from: url) { image in
                        DispatchQueue.main.async {
                            // Set the image for the button's normal state
                            self.profilePic.setImage(image, for: .normal)
                            // Set the imageView's content mode
                            self.profilePic.imageView?.contentMode = .scaleAspectFill
                            // Apply corner radius to make it circular
                            self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
                            self.profilePic.clipsToBounds = true
                        }
                    }
                }
            case .failure(let error):
                print("Error fetching LINE user info: \(error)")
            }
        }
    }
    
    
    func updateProfileInfo(user: GIDGoogleUser) {
        // Assuming you want the profile image URL
        if let imageUrl = user.profile?.imageURL(withDimension: 80) {
            downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    self.profilePic.setImage(image, for: .normal)
                    self.profilePic.imageView?.contentMode = .scaleToFill
                    
                    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
                    self.profilePic.clipsToBounds = true
                }
            }
        }
    }
    
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let urlNS = url as NSURL
        if let cachedImage = ImageCache.getImage(url: urlNS) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image.")
                completion(nil)
                return
            }
            
            ImageCache.setImage(url: urlNS, image: image)
            completion(image)
        }.resume()
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let infoWindow = CustomInfoWindow()
        infoWindow.frame = CGRect(x:0, y:0, width: 300, height: 200)
        infoWindow.titleLabel.text = marker.title
        infoWindow.snippetLabel.text = marker.snippet
        
        
        
        if let metaData = marker.userData as? GMSPlacePhotoMetadata {
            print("Userdata is valid")
            self.marker.loadPhoto(metaData) { photo in
                if let photo = photo {
                    DispatchQueue.main.async {
                        marker.tracksInfoWindowChanges = true
                        infoWindow.pictureView.image = photo
                        marker.tracksInfoWindowChanges = false
                    }
                }
            }
        }
        //animate
        
        return infoWindow
    }
    func setupStyle() {
        navigationView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8272664657)
        setupBorder(button30)
        setupBorder(button45)
        setupBorder(button60)
        setupBorder(button90)
        setupBorder(startButton)
    }
    func setupBorder (_ a: UIButton){
        a.layer.borderWidth = 4
        a.layer.borderColor = #colorLiteral(red: 0.5058823529, green: 0.6274509804, blue: 0.9098039216, alpha: 1)
        a.layer.cornerRadius = a.frame.width / 2
    }
    
}
