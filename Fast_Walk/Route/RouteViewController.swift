import UIKit
import GoogleMaps
import CoreLocation

class RouteViewController: HealthKitDemoViewController, CLLocationManagerDelegate {
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet var currentMode: UILabel!
    @IBOutlet var currentTime: UILabel!
    @IBOutlet var nextMode: UILabel!
    var routeDetails: RouteDetails?
    var mapView: GMSMapView?
    
    
    var mode: String = "slow"
    var timer: Timer!
    var countdown: Int = 0
    var start: String = "start"
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocationCoordinate2D?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        beginLocationUpdate() // Start location updates

        if let routeDetails = routeDetails {
            setupAndDisplayRouteOnMap(routeDetails: routeDetails)
        }

        modeSwitch()
        configureLocationManager()
        
        setupCircularProgressView()
        //setup timer circle view shape.
        currentTime.layer.backgroundColor = UIColor.white.cgColor
        currentTime.layer.borderWidth = 8
        currentTime.layer.borderColor = UIColor.systemBlue.cgColor
        currentTime.textColor = .systemBlue
        currentTime.layer.cornerRadius = currentTime.frame.size.height / 2
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let routeDetails = routeDetails {
            setupAndDisplayRouteOnMap(routeDetails: routeDetails)
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
    
    @IBAction func endTimer() {
        if timer != nil{
            timer.invalidate()
        }
        
       
        
    }
    
    func startTimer(resume: Bool)  {

        if resume != true {
            countdown = 10
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
        
        currentTime.text = String(format: "%02d:%02d", remainingMinutes, remainingSeconds)
        countdown -= 1
        
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
        super.fetchStepData()
        if mode == "slow" {
            currentMode.text = "ゆっくり歩き"
            nextMode.text = "Next: さっさか歩き"
        } else if mode == "fast" {
            currentMode.text = "さっさか歩き"
            nextMode.text = "Next: ゆっくり歩き"
        }
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            currentLocation = location.coordinate
            let cameraUpdate = GMSCameraUpdate.setTarget(location.coordinate, zoom: 10.0)
            mapView?.animate(with: cameraUpdate)
            mapView?.isMyLocationEnabled = true
            mapView?.settings.myLocationButton = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }

    func setupAndDisplayRouteOnMap(routeDetails: RouteDetails) {
        // Set up the map view with the start coordinate of the route
        let camera = GMSCameraPosition.camera(withLatitude: routeDetails.startCoordinate.latitude,
                                              longitude: routeDetails.startCoordinate.longitude,
                                              zoom: 10.0)
        mapView = GMSMapView.map(withFrame: mapContainerView.bounds, camera: camera)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapContainerView.addSubview(mapView!)

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let path = GMSPath(fromEncodedPath: routeDetails.polyString) {
                let bounds = GMSCoordinateBounds(path: path)
                let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
                self.mapView?.animate(with: update)
            }
        }
    }
    
    func beginLocationUpdate() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
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


}

