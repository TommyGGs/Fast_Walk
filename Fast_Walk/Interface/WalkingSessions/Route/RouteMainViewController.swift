
import UIKit
import MapKit
import GoogleMaps
import GooglePlaces
import CoreLocation

class RouteMainViewController: UIViewController, UISearchResultsUpdating, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapContainerView: UIView!
    var mapView: GMSMapView!
    let searchVC = UISearchController(searchResultsController: ResultsViewController())
    var currentLocation: CLLocationCoordinate2D?
    var locationManager = CLLocationManager()
    var marker = Marker()
    let randomwaypoint = randomWayPoint()
    var errorLabelReference: UILabel?
    
    var desiredType: String?
    
    var titleLabel: UILabel!
    var backButton: UIButton!
    
    // MARK: Route Polyline
    var currentRoutePolyline: GMSPolyline?
    var destination: GMSPlace?
    
    // MARK: Passing route info
    var storedRouteDetails: RouteDetails?
    var passWaypoint: [GMSPlace] = []
    
    private var placesClient: GMSPlacesClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        placesClient = GMSPlacesClient.shared()
        setupMapView()
        searchVCStuff()
        beginLocationUpdate()
        locationManager.delegate = self
        self.view.sendSubviewToBack(mapContainerView)
    }

    
    func searchVCStuff() {
        navigationController?.setNavigationBarHidden(true, animated: false)

        let customNavBar = UIView()
        customNavBar.backgroundColor = .white
        customNavBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customNavBar)

        // Add constraints for the custom navigation bar
        NSLayoutConstraint.activate([
            customNavBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            customNavBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            customNavBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            customNavBar.heightAnchor.constraint(equalToConstant: 120)
        ])

        // Add back button and title label
        setupBackButton(to: customNavBar)
        addTitleLabel(to: customNavBar)

        // Add search bar below the title label
        searchVC.searchResultsUpdater = self
        searchVC.obscuresBackgroundDuringPresentation = false
        searchVC.searchBar.placeholder = "目的地を検索する"
        searchVC.searchBar.translatesAutoresizingMaskIntoConstraints = true
        customNavBar.addSubview(searchVC.searchBar)

        // Set search bar constraints
        NSLayoutConstraint.activate([
            searchVC.searchBar.leadingAnchor.constraint(equalTo: customNavBar.leadingAnchor, constant: 16),
            searchVC.searchBar.trailingAnchor.constraint(equalTo: customNavBar.trailingAnchor, constant: -16),
            searchVC.searchBar.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            searchVC.searchBar.heightAnchor.constraint(equalToConstant: 40)
        ])

        // Force layout update to ensure everything is displayed immediately
        customNavBar.layoutIfNeeded()
    }

    
    func addTitleLabel(to parentView: UIView) {
        // Create the label
        titleLabel = UILabel()
        titleLabel.text = "ルートコース"
        titleLabel.font = UIFont(name: "NotoSansJP-Medium", size: 28) // Noto Sans JP Medium font
        titleLabel.textColor = .black
        titleLabel.alpha = 1 // Fully visible
        titleLabel.translatesAutoresizingMaskIntoConstraints = false // Set to false for Auto Layout

        // Add the label to the parent view (custom navigation bar)
        parentView.addSubview(titleLabel)

        // Set constraints for the label to be at the bottom of the navigation bar
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 55), // Align with left side of the parent
            titleLabel.trailingAnchor.constraint(equalTo: parentView.trailingAnchor, constant: -16), // Optional: Align with the right side too
            titleLabel.bottomAnchor.constraint(equalTo: parentView.bottomAnchor, constant: -15) // Anchor it to the bottom of the parent with some padding
        ])
    }




    func setupBackButton(to parentView: UIView) {
        // Create a custom back button
        backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "Backbutton.png"), for: .normal)
        backButton.tintColor = UIColor(red: 84/255.0, green: 84/255.0, blue: 84/255.0, alpha: 0.9)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        backButton.translatesAutoresizingMaskIntoConstraints = false

        // Add the button to the parent view (custom navigation bar)
        parentView.addSubview(backButton)

        // Set constraints for the back button (at the top-left)
        NSLayoutConstraint.activate([
//            backButton.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
//            backButton.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 20), // Top-left position
//            backButton.widthAnchor.constraint(equalToConstant: 30),
//            backButton.heightAnchor.constraint(equalToConstant: 30)
            
            backButton.leadingAnchor.constraint(equalTo: parentView.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: parentView.topAnchor, constant: 70), // Adjust based on the search bar's position
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        
    }

    @objc func backButtonTapped() {
        // Handle the back button tap
        print("button tapped")
        let storyboard = UIStoryboard(name: "RouteOrTime", bundle: nil)
        if let chooseVC = storyboard.instantiateViewController(withIdentifier: "RouteOrTimeViewController") as? RouteOrTimeViewController {
            chooseVC.modalPresentationStyle = .fullScreen
            self.present(chooseVC, animated: false, completion: nil)
        }
    }





    
    
    func setupMapView() {
        print("setting up Map View")
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 20.0)
        mapView = GMSMapView.map(withFrame: mapContainerView.bounds, camera: camera)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView.delegate = self // Set the delegate after initializing the mapView
        
        mapContainerView.addSubview(mapView)
        mapContainerView.sendSubviewToBack(mapView)
        beginLocationUpdate()
    }
    
    func beginLocationUpdate() {
        print("beginning location update")
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else { return }
        
        if currentLocation == nil {  // Check if the initial location has been set
            currentLocation = location.coordinate
            print("LOCATION COORDINATE IS:\(location.coordinate)")
            print("LOCATION COORDINATE IS:\(String(describing: currentLocation))")
            let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                                  longitude: location.coordinate.longitude, zoom: 15.0)
            mapView.camera = camera
            mapView.isMyLocationEnabled = true
            mapView.settings.myLocationButton = true
            mapView.settings.zoomGestures = true
            
        }
    }
    
    
    func updateMapCamera(_ coordinate: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 20.0)
        mapView.animate(with: cameraUpdate)
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              !query.trimmingCharacters(in: .whitespaces).isEmpty,
              let resultsVC = searchController.searchResultsController as? ResultsViewController else {
            return
        }
        
        resultsVC.delegate = self
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case.success(let places):
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case.failure(let error):
                print(error)
            }
        }
    }
    
    // MARK: Destination Route
    @IBAction func destinationRoute(_ sender: UIButton) {
        currentRoutePolyline?.map = nil
        currentRoutePolyline = nil
        mapView?.clear()

        guard let destination = destination else {
            errorLabel(type: "Time")
            return
        }
        
        if let currentLocation = currentLocation,
           let buttonText = sender.titleLabel?.text{
            let desiredTime = checkDesiredTime(buttonText: buttonText)
            print("Desired time: \(String(describing: desiredTime))")
            findBestRoute(from: currentLocation, desiredTime: desiredTime)
//            routeToPlace(destination: destination.coordinate)
        } else {
            print("Current location is not available or no destination")
            
        }
    }
    
    func checkDesiredTime(buttonText: String) -> Int {
        if buttonText == "そのまま" {
            return 0
        }
        let pattern = "\\+(\\d+)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []),
           let match = regex.firstMatch(in: buttonText, range: NSRange(location: 0, length: buttonText.utf16.count)),
           let range = Range(match.range(at: 1), in: buttonText),
           let desiredTime = Int(buttonText[range]) {
            return desiredTime
        }
        return 0
    }
    
    // MARK: Display Route
    func displayRouteOnMap(polyString: String, start: CLLocationCoordinate2D, end: CLLocationCoordinate2D, durationText: String) {
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
    
    
    // MARK: - Make Route with Waypoints
    func findBestRoute(from start: CLLocationCoordinate2D, desiredTime: Int) {
        var closestDuration = Int.max
        var bestRouteDetails: (polyString: String, durationText: String)?
        let group = DispatchGroup()
        //
        //        for _ in 1...2 {
        group.enter()
        guard let currentLocation = currentLocation,
              let destination = destination else{ print("can't search route"); return}
        
        randomwaypoint.findRoute(currentLocation, desiredTime: desiredTime, types: "restaurant" , mode: "Route") { placeInfos in
            for placeInfo in placeInfos {
                if let placeInfo = placeInfo{
                    print("placeInfo:", placeInfo)
                    DispatchQueue.main.async{
                        self.marker.addMarker(placeInfo, self.mapView)
                        guard let destination = self.destination else{return}
                        self.marker.addMarker(destination, self.mapView)
                    }
                    self.passWaypoint.append(placeInfo)
                }
            }
                
            self.requestRoute(from: currentLocation, to: destination.coordinate, waypoints: placeInfos.map(\.!.coordinate)) { polyString, duration in
                let durationInMinutes = duration / 60
                if abs(durationInMinutes - desiredTime) < abs(closestDuration - desiredTime) {
                    closestDuration = durationInMinutes
                    bestRouteDetails = (polyString, "\(durationInMinutes) 分")
                }
                self.displayRouteOnMap(polyString: polyString, start: currentLocation, end: destination.coordinate, durationText: "\(duration / 60) min")
                group.leave()
            }
            
        }
        
        group.notify(queue: .main) {
            if let routeDetails = bestRouteDetails {
                self.storedRouteDetails = RouteDetails(
                    polyString: routeDetails.polyString,
                    durationText: routeDetails.durationText,
                    startCoordinate: start
                )
            } else {
            }
        }
    }
        // MARK: - Make Route
        func requestRoute(from start: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D], completion: @escaping (String, Int) -> Void) {
            let waypointsString = waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
            let origin = "\(start.latitude),\(start.longitude)"
            let encodedWaypoints = waypointsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let destinationString = "\(destination.latitude),\(destination.longitude)"
            let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destinationString)&waypoints=\(encodedWaypoints)&mode=walking&key=\(APIKeys.shared.GMSServices)"
            
            print("https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destinationString)&waypoints=\(encodedWaypoints)&mode=walking&key=\(APIKeys.shared.GMSServices)")
            
            guard let url = URL(string: urlString) else {
                print("Invalid URL")
                completion("", Int.max)
                return
            }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let error = error {
                    print("Network error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        completion("", Int.max)
                    }
                    return
                }
                
                guard let data = data else {
                    DispatchQueue.main.async {
                        print("No data received")
                        completion("", Int.max)
                    }
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                    
                    guard let routes = json["routes"] as? [Any], !routes.isEmpty,
                          let route = routes[0] as? [String: Any],
                          let overviewPolyline = route["overview_polyline"] as? [String: Any],
                          let polyString = overviewPolyline["points"] as? String,
                          let legs = route["legs"] as? [[String: AnyObject]] else {
                        DispatchQueue.main.async {
                            completion("", Int.max)
                        }
                        return
                    }
                    
                    let totalDurationSeconds = legs.compactMap { $0["duration"] as? [String: AnyObject] }.compactMap { $0["value"] as? Int }.reduce(0, +)
                    DispatchQueue.main.async {
                        completion(polyString, totalDurationSeconds)
                    }
                } catch {
                    DispatchQueue.main.async {
                        print("JSON parsing error")
                        completion("", Int.max)
                    }
                }
            }.resume()
        }
        
        // MARK: change navbar style
        func setupNavigationBarStyle() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor.clear // Make nav bar transparent
            appearance.shadowColor = nil // Remove shadow line for cleaner look
            
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
    
        //MARK: - go to routeviewcontroller
        // select button
        @IBAction func selectRoute() {
            if storedRouteDetails != nil {
                self.presentRouteViewController()
            } else {
                errorLabel(type:"Start")
            }
        }
    
        private func presentRouteViewController() {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let routeViewController = storyboard.instantiateViewController(withIdentifier: "RouteViewController") as? RouteViewController,
               let _ = storedRouteDetails {
                routeViewController.routeDetails = storedRouteDetails
                guard let destination = destination else {
                    return
                }
                self.passWaypoint.append(destination)
                routeViewController.waypoints = passWaypoint
                print("waypoint passed", passWaypoint)
                routeViewController.modalPresentationStyle = .fullScreen
                self.present(routeViewController, animated: false, completion: nil)
            } else {
                print("Failed to instantiate RouteViewController")
            }
            print("going to route")
        }
    
        // errorLabel
        func errorLabel(type: String) {
            if errorLabelReference != nil {
                removeErrorLabel()
            }

            let labelWidth: CGFloat = 300
            let labelHeight: CGFloat = 50
            let screenWidth = UIScreen.main.bounds.width
            let labelX = (screenWidth / 2) - (labelWidth / 2)

            let myLabel = UILabel(frame: CGRect(x: labelX, y: 190, width: labelWidth, height: labelHeight))

            if type == "Time" {
                myLabel.text = "目的地を設定してください"
            } else if type == "Start" {
                myLabel.text = "追加の散歩分数を設定してください"
            }

            myLabel.textAlignment = .center
            myLabel.backgroundColor = .red
            myLabel.textColor = .white
            myLabel.layer.cornerRadius = 10
            myLabel.layer.masksToBounds = true
            myLabel.alpha = 0.95

            view.addSubview(myLabel)
            
            // Store reference to the label
            errorLabelReference = myLabel
        }

    
        // MARK: delete error label
        func removeErrorLabel() {
            // Check if the label exists and remove it
            if let label = errorLabelReference {
                label.removeFromSuperview()
                errorLabelReference = nil // Clear the reference after removing
            }
        }

    
        // MARK: end -
    
        // MARK: putMarker stuff
        func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
            if marker.title == "開始地点"{
                //print ("is start thing clicked")
                return nil
            }
            let infoWindow = CustomInfoWindow()
            infoWindow.frame = CGRect(x:0, y:0, width: 300, height: 200)
            infoWindow.titleLabel.text = marker.title
            infoWindow.snippetLabel.text = marker.snippet
            
            
            if let photo = marker.userData as? UIImage {
                print("Userdata is valid")
                DispatchQueue.main.async {
                    marker.tracksInfoWindowChanges = true
                    infoWindow.pictureView.image = photo
                    marker.tracksInfoWindowChanges = false
                }
            }
            return infoWindow
        }
        
    }

    
extension RouteMainViewController: ResultsViewControllerDelegate {
    func didTapPlace(with place: GMSPlace, placeName: String ) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.searchBar.text = placeName
        searchVC.dismiss(animated: false, completion: nil)
        mapView.clear()
        
        
        
        destination = place
        removeErrorLabel()
        print("setting destination to:", place)
        // MARK: set coordinate as marker
        let coordinate = CLLocationCoordinate2D(latitude: place.coordinate.latitude, longitude: place.coordinate.longitude)
        
        
        let marker = GMSMarker(position: coordinate)
        marker.title = placeName
        marker.map = mapView
        
        // Center the map on the new marker
        let camera = GMSCameraPosition.camera(withLatitude: coordinate.latitude, longitude: coordinate.longitude, zoom: 15)
        mapView.animate(to: camera)
    }
    
}
