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
    @IBOutlet var endBtn: UIButton!
    var waypoints: [GMSPlace] = []
    var destination: GMSPlace?
    var overlayView: UIView!
    var countdownLabel: UILabel!
    var routeDetails: RouteDetails?
    var mapView: GMSMapView?
    var marker = Marker()
    var mode: String = "slow"
    var timer: Timer!
    var countdown: Int = 0
//    var duration: Int = 0
    
    var start: String = "start"
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?
    var favorites: [FavoriteSpot] = []
    var user_favorites: [FavoriteSpot] = []
    var remove_user_favorites: [FavoriteSpot] = []
    var allUsers: [User] = []
    var currentSpot: CLLocationCoordinate2D = CLLocationCoordinate2D()
    var userID: String = ""
    var currentPlaceID: String = ""
    
    // heart stuff
    var enableHeart: Bool = false
    var errorLabelReference: UILabel?
    let averageWalkingSpeed: Double = 1.2 // Average walking speed in meters per second


    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //users & favorites

        allUsers = readAllUsers()
        user_favorites = readFavorites()
        enableHeartBtn(fill: false, enable: false)

        print("this is user favorites: \(user_favorites)")
        
        //location
        locationManager.delegate = self
        beginLocationUpdate() // Start location updates
        configureLocationManager()
        
        //timer
        modeSwitch()
        setUpTimerView()
        //setupCircularProgressView() //*not used
        
        setUpNextTimerView()
        
        print("waypoints are:", waypoints)
        if let destination = destination {
            self.marker.addMarker(destination, self.mapView)
            let marker = GMSMarker()
            marker.position = destination.coordinate
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupMapView()
        startCountdown()
        currentTimeUnderLine()
        BlueStepLine()
        
    }
    
    func currentTimeUnderLine() {
        // Create a UIView for the line
        let lineView = UIView()
        
        // Set the line color with 17% transparency (#000000 with alpha 0.17)
        lineView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.17)
        
        // Set the line's corner radius to 3
        lineView.layer.cornerRadius = 3
        
        // Set the constraints for the line
        lineView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(lineView)
        
        // Add constraints to position the line
        NSLayoutConstraint.activate([
            // Align center X with the parent view (to center it horizontally)
            lineView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            // Set the line's height to 2
            lineView.heightAnchor.constraint(equalToConstant: 2),
            
            // Set the line's width (you can adjust this value if needed)
            lineView.widthAnchor.constraint(equalToConstant: 150),
            
            // Place the line 10 points below the currentTime label
            lineView.topAnchor.constraint(equalTo: currentTime.bottomAnchor, constant: -70)
        ])
    }
    
    func BlueStepLine() {
        let blueLine = UIView()
        blueLine.translatesAutoresizingMaskIntoConstraints = false
        blueLine.backgroundColor = UIColor(red: 221/255, green: 232/255, blue: 252/255, alpha: 1.0) // #DDE8FC
        
        view.addSubview(blueLine)
        
        NSLayoutConstraint.activate([
            blueLine.centerXAnchor.constraint(equalTo: view.centerXAnchor), // 화면 중앙에 정렬
            blueLine.topAnchor.constraint(equalTo: stepsLabel.bottomAnchor, constant: 1), // stepsLabel 아래 2 포인트 간격
            blueLine.widthAnchor.constraint(equalToConstant: 150), // 선의 길이 150
            blueLine.heightAnchor.constraint(equalToConstant: 5) // 선의 굵기 5
        ])
    }
    
    func setUpTimerView() {
        currentTime.layer.backgroundColor = UIColor.white.cgColor
        currentTime.layer.borderWidth = 10
        currentTime.layer.borderColor = UIColor(red: 79/255, green: 134/255, blue: 255/255, alpha: 1.0).cgColor
        currentTime.textColor = .black
        currentTime.layer.cornerRadius = currentTime.frame.size.height / 2
        
        if let customFont = UIFont(name: "NotoSansJP-ExtraBold", size: 53) {
               currentTime.font = customFont
           } else {
               currentTime.font = UIFont.systemFont(ofSize: 40) // 폰트가 없을 경우 대체 폰트 설정
           }
        
        // Add drop shadow
            currentTime.layer.shadowColor = UIColor.black.cgColor
            currentTime.layer.shadowOpacity = 0.25 // Adjust the opacity (30%)
            currentTime.layer.shadowOffset = CGSize(width: 0, height: 5) // Adjust the shadow's offset
            currentTime.layer.shadowRadius = 10 // Adjust the blur radius
            currentTime.layer.masksToBounds = false
        
        //Mark: overlay-countdownscreen
        
        overlayView = UIView(frame: view.bounds)
        overlayView.backgroundColor = UIColor(red: 218/255, green: 242/255, blue: 255/255, alpha: 0.5) // #DAF2FF with 50% transparency
        overlayView.isHidden = true // Initially hidden
        
        countdownLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        countdownLabel.center = view.center
        countdownLabel.textAlignment = .center

//        overlayView.addSubview(countdownLabel)
//        view.addSubview(overlayView)
        
//        overlayView = UIView(frame: view.bounds)
//        overlayView.backgroundColor = UIColor.white.withAlphaComponent(0.5) // Half-transparent black
//        overlayView.isHidden = true // Initially hidden
//        
        // Countdown Label


        // Set custom font
        if let customFont = UIFont(name: "NotoSansJP-SemiBold.ttf", size: 180) {
            countdownLabel.font = customFont
        } else {
            // Set font color to #5383EC
            countdownLabel.textColor = UIColor(red: 83/255, green: 131/255, blue: 236/255, alpha: 1.0)
        }
            // Fallback to system font if custom font is not available
            //countdownLabel.font = UIFont.systemFont(ofSize: 80, weight: .black
        overlayView.addSubview(countdownLabel)
        view.addSubview(overlayView)
    }
    
    func setUpNextTimerView() {
        nextMode.layer.backgroundColor = UIColor.white.cgColor
        nextMode.layer.borderWidth = 5
        nextMode.textColor = UIColor.black
        nextMode.layer.borderColor = UIColor(red: 255/255, green: 109/255, blue: 118/255, alpha: 0.34).cgColor // #FF6D76 with 34% opacity
        //nextMode.textColor = .black
        nextMode.layer.cornerRadius = nextMode.frame.size.height / 2
        
        if let customFont = UIFont(name: "NotoSansJP-Regular", size: 12) {
            nextMode.font = customFont
        } else {
            currentTime.font = UIFont.systemFont(ofSize: 12) // 폰트가 없을 경우 대체 폰트 설정
        }
    }
    
    func readFavorites() -> [FavoriteSpot] {
        let favorites = Array(realm.objects(FavoriteSpot.self))
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
        
        var isFavAlready: Bool = false
        var inArrayAlready: Bool = false
        
        removeErrorLabel()
        print("setting up pop-up")
        if marker.title == "開始地点"{
            //print ("is start thing clicked")
            return nil
        } else if marker.title == "終着地点"{
            print("is destination")
            return nil
        }
        
        let infoWindow = CustomInfoWindow()
        infoWindow.frame = CGRect(x:0, y:0, width: 300, height: 200)
        infoWindow.titleLabel.text = marker.title
        
        // Extract rating and type from marker.snippet
        let snippetComponents = marker.snippet?.split(separator: ",")
        if let components = snippetComponents {
            if components.count >= 2 {
                // Extract rating
                let ratingString = components[0].replacingOccurrences(of: "評価：", with: "").trimmingCharacters(in: .whitespaces)
                print("rating is:", ratingString)

                if let ratingDouble = Double(ratingString) {
                    let rating = Int(round(ratingDouble))
                    infoWindow.updateStars(rating: rating)
                } else {
                    print("Invalid rating value")
                }

                // Extract type
                let typeString = components[1].replacingOccurrences(of: "ジャンル：", with: "").trimmingCharacters(in: .whitespaces)
                let typeAttributedString = NSMutableAttributedString(string: "ジャンル：", attributes: [.font: UIFont.boldSystemFont(ofSize: infoWindow.snippetLabel.font.pointSize)])
                typeAttributedString.append(NSAttributedString(string: typeString))
                infoWindow.snippetLabel.attributedText = typeAttributedString

                // Extract opening hours if available
                if components.count >= 3 {
                    let openingHoursString = components[2].replacingOccurrences(of: "営業時間：", with: "").trimmingCharacters(in: .whitespaces)
                    let hoursAttributedString = NSMutableAttributedString(string: "営業時間：", attributes: [.font: UIFont.boldSystemFont(ofSize: infoWindow.hoursLabel.font.pointSize)])
                    hoursAttributedString.append(NSAttributedString(string: openingHoursString))
                    infoWindow.hoursLabel.attributedText = hoursAttributedString
                } else {
                    infoWindow.hoursLabel.text = "営業時間情報なし" // Set a default value if opening hours are not available
                }
            }
        }



        currentSpot = marker.position
        
// TODO: - have placeID stored in favorites
        for waypoint in waypoints {
            if waypoint.coordinate.latitude == currentSpot.latitude, waypoint.coordinate.longitude == currentSpot.longitude {
                currentPlaceID = waypoint.placeID ?? "nil"
            }
        }
        print("current spot changed\(currentSpot)")
//        likeLabel.isHidden = false
//        heartBtn.isHidden = false
        
        
        // MARK: find if it is already in favorite array
        for favorite in favorites {
            if favorite.coordinate.latitude == currentSpot.latitude, favorite.longitude == currentSpot.longitude {
                inArrayAlready = true
                print("is fav array already so fill it")
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
                    print("was in remove already")
                    isFavAlready = false
                }
            }
            
        }
        
        print(favorites, remove_user_favorites)
        
        print("current location at", currentLocation, "current pin at", currentSpot)
 
        if currentSpot.latitude == currentLocation?.latitude && currentSpot.longitude == currentLocation?.longitude {
            print("its at current spot")
            enableHeartBtn(fill: false, enable: false)
        } else if isFavAlready == true {
            enableHeartBtn(fill: true)
        } else if inArrayAlready == true {
            print("already in array")
            enableHeartBtn(fill: true)
        } else if isFavAlready == false{
            print("the isfav already is false")
            enableHeartBtn(fill: false)
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
//        likeLabel.isHidden = true
//        heartBtn.isHidden = true
        removeErrorLabel()
        enableHeartBtn(fill: false, enable: false)
        print("Map didn't tap marker")
    }


    
    @IBAction func likeLocation() {
        guard enableHeart == true else{
            errorLabel()
            print("heart is not enabled")
            return
        }
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        
        if heartBtn.imageView?.image == UIImage(systemName: "heart", withConfiguration: config) {
            enableHeartBtn(fill: true)
            
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
        } else if heartBtn.imageView?.image == UIImage(systemName: "heart.fill", withConfiguration: config){
            print("heart image will be unfilled")
            enableHeartBtn(fill: false)
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
        } 
//        else if start == "running"{
//            start = "paused"
//            timer.invalidate()
//            timer = nil
//        } else if start == "paused"{
//            start = "running"
//            startTimer(resume: true)
//        }
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
//        let remainingMinutes: Int = countdown / 60
//        let remainingSeconds: Int = countdown % 60
//        let durationMinutes: Int = duration / 60
//        let durationSeconds: Int = duration % 60
//        currentTime.text = String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
//        countdown -= 1
//        //gpt changed here
//        super.duration += 1
        
        
        let remainingMinutes: Int = countdown / 60
        let remainingSeconds: Int = countdown % 60
        currentTime.text = String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
        countdown -= 1
        duration += 1 // Increment duration in seconds

        // Calculate total distance based on fixed average walking speed
        totalDistance = Double(duration) * averageWalkingSpeed 
        
        print("total distance now is\(duration)*\(averageWalkingSpeed)")// Distance in meters

        // Optionally, update UI with total distance
        let distanceInKilometers = totalDistance / 1000.0
        totalDistance = distanceInKilometers
        print("distance is now at", distanceInKilometers)
        DispatchQueue.main.async {
//            self.stepsLabel.text = String(format: "合計: %.2f km", distanceInKilometers)
        }
//
//        if countdown < 0 {
//            // You can remove mode switches if they are not needed
//            startTimer(resume: false)
//        }
//        
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
        //add
        let currentModeFont = UIFont(name: "NotoSansJP-Light", size: 19) // Font size 19 for current mode
        let nextModeFont = UIFont(name: "NotoSansJP-Light", size: 12) // Font size 10 for next mode
        //let font = UIFont(name: "NotoSansJP-Light", size: 19) // Adjust size as needed

        if mode == "slow" {
            //play haptics
            CoreHapticsHelp.shared.playHapticPattern("slow")
            currentMode.text = "ゆっくり歩き"
            nextMode.text = "次: さっさか歩き"
        } else if mode == "fast" {
            //play haptics
            CoreHapticsHelp.shared.playHapticPattern("fast")
            currentMode.text = "さっさか歩き"
            nextMode.text = "次: ゆっくり歩き"
        }

        // Apply custom font
        currentMode.font = currentModeFont
        nextMode.font = nextModeFont
       
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
            enableHeartBtn(fill: false, enable: false)
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
            self.marker.addMarker(waypoint, self.mapView, blue: true)
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
            durationMarker.title = "開始地点"
            durationMarker.snippet = "予測時間: \(routeDetails.durationText)"
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
 /*      let circularProgressView = CircularProgressView(frame: CGRect(x: 100, y: 0, width: 100, height: 100))
        circularProgressView.center = CGPoint(x: view.center.x, y: view.center.y - 150) // Adjust position as needed
        circularProgressView.progressColor = .blue // Customize the progress color
        circularProgressView.trackColor = .lightGray // Customize the track color
        circularProgressView.setProgress(to: 0.0) // Initial progress
        view.addSubview(circularProgressView) // Add it to the view
 
        let keejun = CircularProgressBarView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        keejun.center = CGPoint(x: view.center.x, y:view.center.y - 150)
        keejun.setProgress(to: 5.0, animated: true)
        view.addSubview(keejun) // Add it to the view
  */    }
    
    func startCountdown() {
        let countdownNumbers = ["3", "2", "1"]
        var index = 0

        overlayView.isHidden = false
        countdownLabel.isHidden = false

        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else { return }
    
            let font = UIFont(name: "NotoSansJP-SemiBold", size: 150)
            self.countdownLabel.font = font
            self.countdownLabel.textColor = UIColor(red: 67/255, green: 96/255, blue: 249/255, alpha: 1.0)
            
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
    
//    @IBAction func goToEnd(_ sender: UIButton) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let endVC = storyboard.instantiateViewController(withIdentifier: "EndViewController") as? EndViewController {
//            endVC.receivedTime = duration // Set the properties you need to pass
//            
//            // Set the presentation style if necessary (e.g., full screen)
//            endVC.modalPresentationStyle = .fullScreen
//            
//            // Present with animation
//            self.present(endVC, animated: false, completion: nil)
//        }
//    }
//    
    // MARK: - setup Heart Button
    func enableHeartBtn(fill: Bool, enable: Bool = true) {
        print("right now fav array is:", favorites)
//        likeLabel.isHidden = true
//        endBtn.isHidden = true
        
        if enable == true {
            heartBtn.tintColor = .red
            enableHeart = true
        } else {
            heartBtn.tintColor = .lightGray
            enableHeart = false
        }

        heartBtn.frame = CGRect(x: 40, y: 740, width: heartBtn.frame.width, height: heartBtn.frame.height)
        let config = UIImage.SymbolConfiguration(pointSize: 30, weight: .bold, scale: .large)
        
        if fill == true {
            print("heart set to fill")
            let image = UIImage(systemName: "heart.fill", withConfiguration: config)
            heartBtn.setImage(image, for: .normal)
        } else if fill == false{
            print("heart set to not fill")
            let image = UIImage(systemName: "heart", withConfiguration: config)
            heartBtn.setImage(image, for: .normal)
        }
        
        // 제약 설정 (SafeArea의 아래에서 10 포인트, 왼쪽에서 5 포인트 간격)
              let safeArea = view.safeAreaLayoutGuide
              NSLayoutConstraint.activate([
                  heartBtn.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -35),
                  heartBtn.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 50),
                  heartBtn.widthAnchor.constraint(equalToConstant: heartBtn.frame.width),  // 기존의 width 유지
                  heartBtn.heightAnchor.constraint(equalToConstant: heartBtn.frame.height) // 기존의 height 유지
              ])
    }
    
    // MARK: - eror label stuff
    func errorLabel(){
        if errorLabelReference != nil {
            removeErrorLabel()
        }

        let labelWidth: CGFloat = 300
        let labelHeight: CGFloat = 50
        
        // Assuming this code is inside a ViewController method
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let labelX = (screenWidth / 2) - (labelWidth / 2)
        //        let labelY = screenHeight * 0.5
        
        let myLabel = UILabel(frame: CGRect(x: labelX, y: 100, width: labelWidth, height: labelHeight))
        myLabel.text = "保存する場所を選択してください"
        myLabel.textAlignment = .center
        myLabel.backgroundColor = .red // For visibility
        myLabel.textColor = .white
        myLabel.layer.cornerRadius = 10
        myLabel.layer.masksToBounds = true
        myLabel.alpha = 0.95
        
        view.addSubview(myLabel)
        errorLabelReference = myLabel

    }
    
    func removeErrorLabel() {
        print("removing errorlaebl")
        if let label = errorLabelReference {
            label.removeFromSuperview()
            errorLabelReference = nil
        }
    }
}



