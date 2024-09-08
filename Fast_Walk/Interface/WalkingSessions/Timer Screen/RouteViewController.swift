import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import RealmSwift
import GoogleSignIn
import LineSDK


class RouteViewController: HealthKitDemoViewController, CLLocationManagerDelegate,  GMSMapViewDelegate {
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet var currentMode: UILabel!
    @IBOutlet var currentTime: UILabel!
    @IBOutlet var nextMode: UILabel!
    @IBOutlet var heartBtn: UIButton!
    @IBOutlet var likeLabel: UILabel!
    var waypoints: [GMSPlace] = []
    var overlayView: UIView!
    var countdownLabel: UILabel!
    var routeDetails: RouteDetails?
    var mapView: GMSMapView?
    var marker = Marker()
    var mode: String = "slow"
    var timer: Timer!
    var countdown: Int = 0
    var duration: Int = 0
    
    var start: String = "start"
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var favorites: [FavoriteSpot] = []
    var user_favorites: [FavoriteSpot] = []
    var remove_user_favorites: [FavoriteSpot] = []
    var isFavAlready: Bool = false
    var allUsers: [User] = []
    var currentSpot: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var userID: String = ""
    var currentPlaceID: String = ""
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //users & favorites
        allUsers = readAllUsers()
        user_favorites = readFavorites()
        likeLabel.isHidden = true
        heartBtn.isHidden = true
        print("this is user favorites: \(user_favorites)")
        
        //location
        locationManager.delegate = self
        beginLocationUpdate() // Start location updates
        configureLocationManager()
        
        //timer
        modeSwitch()
        //setupCircularProgressView() *not used
        setUpTimerView()
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMapView()
        startCountdown()
    }
    
    func setUpTimerView() {
        currentTime.layer.backgroundColor = UIColor.white.cgColor
        currentTime.layer.borderWidth = 10
        currentTime.layer.borderColor = UIColor(red: 79/255, green: 134/255, blue: 255/255, alpha: 1.0).cgColor
        currentTime.textColor = .black
        currentTime.layer.cornerRadius = currentTime.frame.size.height / 2
        
        if let customFont = UIFont(name: "NotoSansJP-ExtraBold", size: 40) {
               currentTime.font = customFont
           } else {
               currentTime.font = UIFont.systemFont(ofSize: 40) // 폰트가 없을 경우 대체 폰트 설정
           }
        
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.5) // Half-transparent black
        overlayView.isHidden = true // Initially hidden
        
        // Countdown Label
        countdownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        countdownLabel.center = view.center
        countdownLabel.textAlignment = .center

        // Set custom font
        if let customFont = UIFont(name: "NotoSansJP-SemiBold.ttf", size: 180) {
            countdownLabel.font = customFont
        } else {
            // Fallback to system font if custom font is not available
            //countdownLabel.font = UIFont.systemFont(ofSize: 80, weight: .black)
        }

        // Set font color to #5383EC
        countdownLabel.textColor = UIColor(red: 83/255, green: 131/255, blue: 236/255, alpha: 1.0)

        overlayView.addSubview(countdownLabel)
        view.addSubview(overlayView)
    }
    
    func readFavorites() -> [FavoriteSpot] {
        var favorites = Array(realm.objects(FavoriteSpot.self))
        var findFavorites: [FavoriteSpot] = []
        for favorite in favorites {
            if favorite.userID == Current.user.userID {
                print("found user favorites")
                findFavorites.append(favorite)
            }
        }
        return findFavorites
    }
    
    
    func readAllUsers() -> [User] {
        let allUsers = Array(realm.objects(User.self))
        print("realm array:\(Array(realm.objects(User.self)))")
        print("appending all users: \(allUsers)")
        return allUsers
    }
    
    func readUsers() -> User {
        print("reading users")
        return Current.user
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        print("setting up pop-up")
        if marker.title == "Route Start"{
            //print ("is start thing clicked")
            return nil
        }
        let infoWindow = CustomInfoWindow()
        infoWindow.frame = CGRect(x:0, y:0, width: 300, height: 200)
        infoWindow.titleLabel.text = marker.title
        infoWindow.snippetLabel.text = marker.snippet
        currentSpot = marker.position
        
// TODO: - have placeID stored in favorites
        for waypoint in waypoints {
            if waypoint.coordinate.latitude == currentSpot.latitude, waypoint.coordinate.longitude == currentSpot.longitude {
                currentPlaceID = waypoint.placeID ?? "nil"
            }
        }
        print("current spot changed\(currentSpot)")
        likeLabel.isHidden = false
        heartBtn.isHidden = false
        
        var inArrayAlready: Bool = false
        
        // MARK: find if it is already in favorite array
        for favorite in favorites {
            if favorite.coordinate.latitude == currentSpot.latitude, favorite.longitude == currentSpot.longitude {
                inArrayAlready = true
                print("is fav array already")
                heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            }
        }
        
        //MARK: find if it is already in user Array, or remove array
        if inArrayAlready != true {
            for user_fav in user_favorites {
                if user_fav.latitude == currentSpot.latitude, user_fav.longitude == currentSpot.longitude  {
                    isFavAlready = true
                    print("is fav already")
                }
            }
            for remove_user_favorite in remove_user_favorites {
                if remove_user_favorite.longitude == currentSpot.longitude, remove_user_favorite.latitude == currentSpot.latitude {
                    heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
                    print("was in remove already")
                    isFavAlready = false
                }
            }
        }
        
        print(favorites, remove_user_favorites)
        if isFavAlready == true {
            heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        } else if isFavAlready == false{
            heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
        }
        

        
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
    // when tapped map but not marker
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        likeLabel.isHidden = true
        heartBtn.isHidden = true
        print("Map didn't tap marker")
    }


    
    @IBAction func likeLocation() {
        print("button pressed")
        if heartBtn.imageView?.image == UIImage(systemName: "heart") {
            heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
            for remove_favorite in remove_user_favorites{
                if let index = remove_user_favorites.firstIndex(where: {
                    $0.latitude == currentSpot.latitude && $0.longitude == currentSpot.longitude}) {
                    remove_user_favorites.remove(at: index)
                    print("spot removed from remove array")
                }
            }
            let fav = FavoriteSpot(coordinate: currentSpot)
            fav.userName = Current.user.name
            fav.userID = Current.user.userID
            fav.placeID = currentPlaceID
            print("favorite placeID added to array")
            favorites.append(fav)
            print("fav appended")
        } else {
            heartBtn.setImage(UIImage(systemName: "heart"), for: .normal)
            for favorite in favorites {
                if let index = favorites.firstIndex(where: {
                    $0.latitude == currentSpot.latitude && $0.longitude == currentSpot.longitude
                }) {
                    print("remove spot from favorite array")
                    favorites.remove(at: index)
                }
            }
            for user_favorite in user_favorites {
                if user_favorite.latitude == currentSpot.latitude, user_favorite.longitude == currentSpot.longitude{
                    let unfav = FavoriteSpot(coordinate: currentSpot)
                    unfav.userName = Current.user.name
                    unfav.userID = Current.user.userID
                    unfav.placeID = currentPlaceID
                    print("unfavorite placeID added to array")
                    remove_user_favorites.append(unfav)
                    print("added already liked spot to remove array")
                }
            }
        }
    }
    
    @IBAction func startTimer() {
        super.startWorkoutSession()
        
        if start == "start"{
            startTimer(resume: false)
            start = "running"
        } else if start == "running"{
            start = "paused"
            timer.invalidate()
            timer = nil
        } else if start == "paused"{
            start = "running"
            startTimer(resume: true)
        }
    }
    
    
    // add favorite arrays to data base and remove remove array from data base
    @IBAction func endTimer() {
        if timer != nil{
            timer.invalidate()
        }
        try! realm.write{
            for favorite in favorites {
                realm.add(favorite)
                print("favorites create succeeded")
            }
            for remove_favorite in remove_user_favorites {
                realm.delete(remove_favorite)
                print("favorites removed")
            }
        }
    }
    
    
    func startTimer(resume: Bool)  {
        if resume != true {
            if mode == "slow" {
                countdown = 300 //change for timer interval
            } else {
                countdown = 180//change for timer interval
            }
        }
        if timer == nil {
            // Starting or resuming the timer
            timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerCalled), userInfo: nil, repeats: true)
        }
        timer.fire()
    }
    
    @objc func onTimerCalled(){
        let remainingMinutes: Int = countdown / 60
        let remainingSeconds: Int = countdown % 60
        let durationMinutes: Int = duration / 60
        let durationSeconds: Int = duration % 60
        currentTime.text = String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
        countdown -= 1
        duration += 1
        
//        print (String(format: "%02d:%02d", durationMinutes, durationSeconds))
        
        if countdown < 0 {
            if mode == "slow"{
                mode = "fast"
                modeSwitch()
            } else {
                mode = "slow"
                modeSwitch()
            }
            startTimer(resume: false)
        }
    }
    
    func modeSwitch() {
        let font = UIFont(name: "NotoSansJP-Light", size: 18) // Adjust size as needed

        if mode == "slow" {
            //play haptics
            CoreHapticsHelp.shared.playHapticPattern("slow")
            currentMode.text = "ゆっくり歩き"
            nextMode.text = "Next: さっさか歩き"
        } else if mode == "fast" {
            //play haptics
            CoreHapticsHelp.shared.playHapticPattern("fast")
            currentMode.text = "さっさか歩き"
            nextMode.text = "Next: ゆっくり歩き"
        }

        // Apply custom font
        currentMode.font = font
        nextMode.font = font

        // Adjust position
        let yOffset: CGFloat = 14 // Adjust the vertical offset as needed
        currentMode.frame.origin.y += yOffset
        nextMode.frame.origin.y += yOffset
    }
    
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
//            let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: 25)
//            mapView?.animate(with: cameraUpdate)
            mapView?.isMyLocationEnabled = true
            mapView?.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func setupMapView() {
        guard let routeDetails = self.routeDetails else { return }

        let camera = GMSCameraPosition.camera(withLatitude: routeDetails.startCoordinate.latitude,
                                              longitude: routeDetails.startCoordinate.longitude,
                                              zoom: 20.0)
        mapView = GMSMapView.map(withFrame: mapContainerView.bounds, camera: camera)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView?.delegate = self
        mapContainerView.addSubview(mapView!)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true

        setupAndDisplayRouteOnMap(routeDetails: routeDetails)

        for waypoint in waypoints {
            self.marker.addMarker(waypoint, self.mapView)
        }
    }
    
    func setupAndDisplayRouteOnMap(routeDetails: RouteDetails) {
        
        // Display the route
        
        if let path = GMSPath(fromEncodedPath: routeDetails.polyString) {
            let polyline = GMSPolyline(path: path)
            
            polyline.strokeWidth = 5.0
            polyline.strokeColor = UIColor.systemBlue
            polyline.map = mapView
            // Fit the camera to the bounds of the route
            let bounds = GMSCoordinateBounds(path: path)
            print("Polyline bounds: \(bounds)")
            print("Map view frame: \(mapView?.frame ?? CGRect.zero)")
            
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50) // Adjust padding as needed
            mapView?.animate(with: update)
            
            let durationMarker = GMSMarker(position: routeDetails.startCoordinate)
            durationMarker.title = "Route Start"
            durationMarker.snippet = "Estimated Total Walking Time: \(routeDetails.durationText)"
            durationMarker.map = mapView
            mapView?.selectedMarker = durationMarker
        }
    }
    
    func beginLocationUpdate() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
            mapView?.isMyLocationEnabled = true
            mapView?.isMyLocationEnabled = true
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func setupCircularProgressView() {
        let circularProgressView = CircularProgressView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        circularProgressView.center = CGPoint(x: view.center.x, y: view.center.y - 150) // Adjust position as needed
        circularProgressView.progressColor = .blue // Customize the progress color
        circularProgressView.trackColor = .lightGray // Customize the track color
        circularProgressView.setProgress(to: 0.0) // Initial progress
        view.addSubview(circularProgressView) // Add it to the view
    }
    
    func startCountdown() {
        let countdownNumbers = ["3", "2", "1"]
        var index = 0

        overlayView.isHidden = false
        countdownLabel.isHidden = false

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
    
            let font = UIFont(name: "NotoSansJP-SemiBold", size: 17)

            if index < countdownNumbers.count {
                self.countdownLabel.text = countdownNumbers[index]
                self.animateLabel(self.countdownLabel)
                
                index += 1
            } else {
                timer.invalidate()
                self.overlayView.isHidden = true
                self.startTimer()
            }
        }
    }
    
    func animateLabel(_ label: UILabel) {
        label.alpha = 0
        UIView.animate(withDuration: 0.5, animations: {
            label.alpha = 1
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                label.alpha = 0
            }
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if let endVC = segue.destination as? EndViewController {
            endVC.receivedTime = duration
            
        }
    }
}

