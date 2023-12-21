import UIKit
import GoogleMaps

class RouteViewController: UIViewController {
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet var currentMode: UILabel!
    @IBOutlet var currentTime: UILabel!
    var routeDetails: RouteDetails?
    var mapView: GMSMapView?
    
    var mode: String = "slow"
    var timer: Timer!
    var countdown: Int = 0
    var start: String = "start"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let routeDetails = routeDetails {
            setupAndDisplayRouteOnMap(routeDetails: routeDetails)
        }
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
    
    func startTimer(resume: Bool)  {
        if resume != true {
            countdown = 180
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
            } else {
                mode = "slow"
            }
            startTimer(resume: false)
        }
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

            let bounds = GMSCoordinateBounds(path: path)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapView?.animate(with: update)
            
            let durationMarker = GMSMarker(position: routeDetails.startCoordinate)
            durationMarker.title = "Route Start"
            durationMarker.snippet = "Estimated Total Walking Time: \(routeDetails.durationText)"
            durationMarker.map = mapView
            mapView?.selectedMarker = durationMarker
        }
    }
}
