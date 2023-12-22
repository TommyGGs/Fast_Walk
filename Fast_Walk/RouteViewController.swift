import UIKit
import GoogleMaps

class RouteViewController: UIViewController, CLLocationManagerDelegate {
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let routeDetails = routeDetails {
            setupAndDisplayRouteOnMap(routeDetails: routeDetails)
        }
        modeText()
        configureLocationManager()
    }
    
    @IBAction func startTimer() {
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
        timer.invalidate()
        
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
                modeText()
            } else {
                mode = "slow"
                modeText()
            }
            startTimer(resume: false)
        }
    }
    
    func modeText() {
        if mode == "slow" {
            currentMode.text = "ゆっくり歩き"
            nextMode.text = "さっさか歩き"
        } else if mode == "fast" {
            currentMode.text = "さっさか歩き"
            nextMode.text = "ゆっくり歩き"
        }
    }
    
    func configureLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
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
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50) // Adjust padding as needed
            mapView?.animate(with: update)
            
            let durationMarker = GMSMarker(position: routeDetails.startCoordinate)
            durationMarker.title = "Route Start"
            durationMarker.snippet = "Estimated Total Walking Time: \(routeDetails.durationText)"
            durationMarker.map = mapView
            mapView?.selectedMarker = durationMarker
        }
    }
}
