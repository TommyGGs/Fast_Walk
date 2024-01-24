import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import GoogleSignIn
import LineSDK
import RealmSwift



class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var profilePic: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var button30: UIButton!
    @IBOutlet weak var button45: UIButton!
    @IBOutlet weak var button60: UIButton!
    @IBOutlet weak var button90: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var dataButton: UIButton!
    @IBOutlet var accountButton: UIButton!
    
    @IBOutlet var heart: UIButton!
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
    var passWaypoint: [GMSPlace] = []
    
    
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
        //        setupStyle()
        print("passed")
        setupStyle()
        changeRouteButton()
//        self.view.bringSubviewToFront(heartButton)
//        self.view.bringSubviewToFront(homeButton)
//        self.view.bringSubviewToFront(dataButton)
//        self.view.bringSubviewToFront(accountButton)
//        self.view.sendSubviewToBack(mapContainerView)
     }

//    func navBar() {
//        
//        // Create a control bar
//        let controlBar = UIView()
//        controlBar.backgroundColor = UIColor(red: 204/255, green: 217/255, blue: 245/255, alpha: 0.34)
//        controlBar.layer.cornerRadius = 20 // Adjust the corner radius as needed
//        view.addSubview(controlBar)
//
//         // Add constraints to set the control bar's position and size
//         controlBar.translatesAutoresizingMaskIntoConstraints = false
//         NSLayoutConstraint.activate([
//            controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            controlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            controlBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5), // Move lower
//            controlBar.heightAnchor.constraint(equalToConstant: 60) //ここでバーの高さ変更（大きい数＝した）
//         ])
//
//        // Add image buttons to the control bar
//          controlBar.addSubview(heartButton)
//          controlBar.addSubview(homeButton)
//          controlBar.addSubview(dataButton)
//          controlBar.addSubview(accountButton)
//
//        // Add constraints to position the image buttons within the control bar
//        let buttonWidth = (view.frame.width - 40) / 4 // Adjust spacing as needed
//        let buttonHeight: CGFloat = 30 //ここでボタンの高さ変えて（小さい数=もっと高く）
//
//        heartButton.translatesAutoresizingMaskIntoConstraints = false
//        homeButton.translatesAutoresizingMaskIntoConstraints = false
//        dataButton.translatesAutoresizingMaskIntoConstraints = false
//        accountButton.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            heartButton.leadingAnchor.constraint(equalTo: controlBar.leadingAnchor, constant: 10),
//            heartButton.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 10), // Adjust the top anchor
//            heartButton.widthAnchor.constraint(equalToConstant: buttonWidth),
//            heartButton.heightAnchor.constraint(equalToConstant: buttonHeight),
//
//            homeButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: 10),
//            homeButton.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 10), // Adjust the top anchor
//            homeButton.widthAnchor.constraint(equalToConstant: buttonWidth),
//            homeButton.heightAnchor.constraint(equalToConstant: buttonHeight),
//
//            dataButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: 10),
//            dataButton.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 10), // Adjust the top anchor
//            dataButton.widthAnchor.constraint(equalToConstant: buttonWidth),
//            dataButton.heightAnchor.constraint(equalToConstant: buttonHeight),
//
//            accountButton.leadingAnchor.constraint(equalTo: dataButton.trailingAnchor, constant: 10),
//            accountButton.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 10), // Adjust the top anchor
//            accountButton.widthAnchor.constraint(equalToConstant: buttonWidth),
//            accountButton.heightAnchor.constraint(equalToConstant: buttonHeight),
//            
//            // Add trailing constraint to the last button
//            accountButton.trailingAnchor.constraint(equalTo: controlBar.trailingAnchor, constant: -10),
//        ])
//    }
    
    @IBAction func likeLocation() {
        print("pressed heart")
        heart.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    }
    
    func errorLabel(){
        let labelWidth: CGFloat = 250
        let labelHeight: CGFloat = 50
        
        // Assuming this code is inside a ViewController method
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let labelX = (screenWidth / 2) - (labelWidth / 2)
        //        let labelY = screenHeight * 0.5
        
        let myLabel = UILabel(frame: CGRect(x: labelX, y: 55, width: labelWidth, height: labelHeight))
        myLabel.text = "散歩時間を設定してください"
        myLabel.textAlignment = .center
        myLabel.backgroundColor = .red // For visibility
        myLabel.textColor = .white
        myLabel.layer.cornerRadius = 10
        myLabel.layer.masksToBounds = true
        myLabel.alpha = 0.8
        
        view.addSubview(myLabel)
    }
    
    
    
    func createBarButton(title: String, imageName: String, fontSize: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        
        if let image = UIImage(named: imageName) {
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0) // Adjust as needed
        }
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        button.titleLabel?.textAlignment = .center
        
        return button
    }
        


    
    
    
    //コース変更
    func changeRouteButton(){
        let courseChangeButton = UIButton(type: .system)
                courseChangeButton.setTitle("コース変更", for: .normal)
                courseChangeButton.backgroundColor = UIColor(white: 1.0, alpha: 0.4)
                courseChangeButton.layer.cornerRadius = 8
                courseChangeButton.setTitleColor(UIColor.black, for: .normal)

                view.addSubview(courseChangeButton)

                courseChangeButton.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    courseChangeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                    courseChangeButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
                    courseChangeButton.widthAnchor.constraint(equalToConstant: 130),
                    courseChangeButton.heightAnchor.constraint(equalToConstant: 50)
                ])

                courseChangeButton.addTarget(self, action: #selector(courseChangeButtonTapped), for: .touchUpInside)
        
        
        //faded backgroundだよ
        view.backgroundColor = UIColor.white // Replace with your desired color

        let yOffset: CGFloat = 50
        let squareView = UIView(frame: CGRect(x: 0, y:  mapContainerView.bounds.height, width: view.bounds.width, height: 100))
        squareView.layer.cornerRadius = 10
        squareView.clipsToBounds = true

        // Create a gradient layer
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = squareView.bounds
        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
        gradientLayer.locations = [0.8, 3.0] // Adjust the locations to control the fading

        // Adjust startPoint and endPoint to make the gradient upside down
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)

        // Add the gradient layer to the square view's layer
        squareView.layer.addSublayer(gradientLayer)

        // Add the square view to the main view
        view.addSubview(squareView)
        
        // Move the square view to the back of the view hierarchy
        view.sendSubviewToBack(squareView)



        }

    @objc func courseChangeButtonTapped() {
        print("コース変更 button tapped")
        // Implement your action for the button tap here
        
        
    
        
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
            errorLabel()
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
                    self.passWaypoint.append(placeInfo)
                }
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
        if segue.identifier == "showRoute",
           let destinationVC = segue.destination as? RouteViewController,
           let _ = storedRouteDetails {
            destinationVC.routeDetails = storedRouteDetails
            // Assuming storedRouteDetails has the waypoints
            print("passed waypoint")
            destinationVC.waypoints = passWaypoint
            // Replace with actual way to access waypoints
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
        
        
        if let photo = marker.userData as? UIImage {
            print("Userdata is valid")
            DispatchQueue.main.async {
                marker.tracksInfoWindowChanges = true
                infoWindow.pictureView.image = photo
                marker.tracksInfoWindowChanges = false
            }
        }
        return infoWindow // This ensures a UIView? is always returned
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
