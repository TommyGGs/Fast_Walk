////
////  ViewController.swift
////  Fast_Walk
////
////  Created by Tom  on 2023/11/29.
////
//
//import UIKit
//import GoogleMaps
//import CoreLocation
//
//
//class ViewController: UIViewController {
//    @IBOutlet weak var mapView: GMSMapView!
//    @IBOutlet weak var iblTime: UILabel!
//    @IBOutlet weak var iblDistance: UILabel!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        // Do any additional setup after loading the view.
//        // delete
//        mapView.translatesAutoresizingMaskIntoConstraints = false
//       drawGoogleApiDirection()
//
//    }
//
////    func drawGoogleApiDirection() {
////        let origin = "\(24.871941), \(66.988060)"
////        let destination = "\(24.885958), \(67.026744)"
////
////        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"
////
////        let url = URL(string: urlString)
////        URLSession.shared.dataTask(with: url!, completionHandler: {
////            (data, response, error) in
////            if(error != nil){
////                print("error")
////            }else{
////
////                DispatchQueue.main.async {
////                    self.mapView.clear()
////                    self.addSourceDestinationMarkers()
////                }
////
////                do{
////                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as![String: AnyObject]
////                    let routes = json["routes"] as! NSArray
////
////                    self.getTotalDistance()
////
////                    OperationQueue.main.addOperation({
////                        for route in routes {
////                            let routeOverviewPolyline:NSDictionary = (route as! NSDictionary).value(forKey: "overview_polyline") as! NSDictionary
////                            let points = routeOverviewPolyline.object(forKey: "points")
////                            let path = GMSPath.init(fromEncodedPath: points! as! String)
////                            let polyline = GMSPolyline.init(path: path)
////                            polyline.strokeWidth = 3
////                            polyline.strokeColor = UIColor(red: 50/255, green: 165/255, blue: 102/255, alpha: 1.0)
////
////                            let bounds = GMSCoordinateBounds(path: path!)
////                            self.mapView?.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
////
////
////                            polyline.map = self.mapView
////                        }
////                    })
////                } catch let error as NSError{
////                    print("error:\(error)")
////                }
////            }
////        }).resume()
////
////    }
//
//    func drawGoogleApiDirection() {
//        let origin = "\(24.871941), \(66.988060)"
//        let destination = "\(24.885958), \(67.026744)"
//
////        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc") else {
////            print("Invalid URL")
////            return
////        }
////
//        let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(origin)&destinations=\(destination)&units=imperial&mode=driving&language=en-EN&sensor=false&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"
//
//
//        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
//            if let error = error {
//                print("Error: \(error)")
//            } else {
//                DispatchQueue.main.async {
//                    self?.mapView?.clear()
//                    self?.addSourceDestinationMarkers()
//                }
//
//
//                do {
//                    if let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? [String: AnyObject],
//                       let routes = json["routes"] as? NSArray {
//
//                        self?.getTotalDistance()
//
//                        OperationQueue.main.addOperation {
//                            for route in routes {
//                                if let routeOverviewPolyline = (route as? NSDictionary)?.value(forKey: "overview_polyline") as? NSDictionary,
//                                   let points = routeOverviewPolyline.object(forKey: "points") as? String,
//                                   let path = GMSPath(fromEncodedPath: points) {
//
//                                    let polyline = GMSPolyline(path: path)
//                                    polyline.strokeWidth = 3
//                                    polyline.strokeColor = UIColor(red: 50/255, green: 165/255, blue: 102/255, alpha: 1.0)
//
//                                    if let mapView = self?.mapView {
//                                        let bounds = GMSCoordinateBounds(path: path)
//                                        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
//                                        polyline.map = mapView
//                                    }
//                                }
//                            }
//                        }
//                    }
//                } catch let error as NSError {
//                    print("Error: \(error)")
//                }
//            }
//        }.resume()
//    }
//
//
//    func addSourceDestinationMarkers() {
//        let markerSource = GMSMarker()
//        markerSource.position = CLLocationCoordinate2D(latitude: 24.871941, longitude: 66.988060)
//        markerSource.icon = UIImage(named: "markera")
//        markerSource.title = "Point A"
//
//        markerSource.map = mapView
//
//        let markerDestination = GMSMarker()
//        markerDestination.position = CLLocationCoordinate2D(latitude: 24.885958, longitude: 67.026744)
//        markerDestination.icon = UIImage(named: "markerb")
//        markerDestination.title = "Point B"
//
//        markerDestination.map = mapView
//    }
//
//
//    func getTotalDistance() {
//        let origin = "\(24.871941), \(66.988060)"
//        let destination = "\(24.885958), \(67.026744)"
//
//        let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?=\(origin)&destinations=\(destination)&units=imperial&mode=driving&language=en-EN&sensor=false&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"
//
//        let url = URL(string: urlString)
//        URLSession.shared.dataTask(with: url!, completionHandler: {
//            (data, response, error) in
//            if (error != nil){
//                print("error")
//            } else{
//                do{
//                    let json = try JSONSerialization.jsonObject(with: data!, options:.allowFragments) as! [String: AnyObject]
//                    let rows = json["rows"] as! NSArray
//                    print(rows)
//
//                    let dic = rows[0] as! Dictionary<String, Any>
//                    let elements = dic["elements"] as! NSArray
//                    let dis = elements[0] as! Dictionary<String, Any>
//                    let distanceMiles = dis["distance"] as! Dictionary<String, Any>
//                    let miles = distanceMiles["text"]! as! String
//
//                    self.iblDistance.text = miles.replacingOccurrences(of: "mi", with: "")
//                    print("\(String(describing: self.iblDistance.text))")
//
//                } catch let error as NSError{
//                    print("error:\(error)")
//                }
//            }
//        }).resume()
//    }
//}
//import UIKit
//import GoogleMaps
//import CoreLocation
//
//class ViewController: UIViewController {
//    @IBOutlet weak var mapView: GMSMapView!
//
//    @IBOutlet weak var iblTime: UILabel!
//    @IBOutlet weak var iblDistance: UILabel!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        mapView.translatesAutoresizingMaskIntoConstraints = false
//        drawGoogleApiDirection()
//    }
//
//    func drawGoogleApiDirection() {
//        let origin = "24.871941,66.988060"
//        let destination = "24.885958,67.026744"
//
//        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(destination)&mode=driving&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc"
////
//        let url = URL(string: urlString)
////        guard let encodedOrigin = origin.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
////              let encodedDestination = destination.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
////              let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(encodedOrigin)&destination=\(encodedDestination)&mode=driving&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc") else {
////            print("Invalid URL")
////            return
////        }
//
//        URLSession.shared.dataTask(with: url!, completionHandler: {
//            (data,response, error) in
//            if (error != nil) {
//                print("error")
//            } else {
//                DispatchQueue.main.async {
//                    self.mapView.clear()
//                    self.addSourceDestinationMarkers()
//                }
//
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
//                    let routes = json["routes"] as! NSArray
//
//                        self?.getTotalDistance()
//
//                        OperationQueue.main.addOperation {
//                            for route in routes {
//                                if let routeOverviewPolyline = (route as! NSDictionary)?.value(forKey: "overview_polyline") as! NSDictionary,
//                                   let points = routeOverviewPolyline.object(forKey: "points") as? String,
//                                   let path = GMSPath(fromEncodedPath: points) {
//
//                                    let polyline = GMSPolyline(path: path)
//                                    polyline.strokeWidth = 3
//                                    polyline.strokeColor = UIColor(red: 50/255, green: 165/255, blue: 102/255, alpha: 1.0)
//
//                                    if let mapView = self?.mapView {
//                                        let bounds = GMSCoordinateBounds(path: path)
//                                        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 30.0))
//                                        polyline.map = mapView
//                                    }
//                                }
//                            }
//                        }
//
//                } catch let error as NSError {
//                    print("Error: \(error)")
//                }
//            }
//        }.resume()
//    }
//
//    func addSourceDestinationMarkers() {
//        let markerSource = GMSMarker()
//        markerSource.position = CLLocationCoordinate2D(latitude: 24.871941, longitude: 66.988060)
//        markerSource.icon = UIImage(named: "markera")
//        markerSource.title = "Point A"
//
//        markerSource.map = mapView
//
//        let markerDestination = GMSMarker()
//        markerDestination.position = CLLocationCoordinate2D(latitude: 24.885958, longitude: 67.026744)
//        markerDestination.icon = UIImage(named: "markerb")
//        markerDestination.title = "Point B"
//
//        markerDestination.map = mapView
//    }
//
//    func getTotalDistance() {
//        let origin = "24.871941,66.988060"
//        let destination = "24.885958,67.026744"
//
//        guard let urlString = "https://maps.googleapis.com/maps/api/distancematrix/json?origins=\(origin)&destinations=\(destination)&units=imperial&mode=driving&language=en-EN&sensor=false&key=AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc".addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
//              let url = URL(string: urlString) else {
//            print("Invalid URL")
//            return
//        }
//
//        URLSession.shared.dataTask(with: url) { (data, response, error) in
//            if error != nil {
//                print("error")
//            } else {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String: AnyObject]
//                    let rows = json["rows"] as! NSArray
//                    print(rows)
//
//                    let dic = rows[0] as! Dictionary<String, Any>
//                    let elements = dic["elements"] as! NSArray
//                    let dis = elements[0] as! Dictionary<String, Any>
//                    let distanceMiles = dis["distance"] as! Dictionary<String, Any>
//                    let miles = distanceMiles["text"]! as! String
//
//                    let TimeRide = dis["duration"] as! Dictionary<String, Any>
//                    let finalTime = TimeRide["text"]! as! String
//
//                    DispatchQueue.main.async {
//                        self.iblDistance.text = miles
//                        self.iblTime.text = finalTime
//                        print("\(String(describing: self.iblDistance.text))")
//                    }
//                } catch let error as NSError {
//                    print("error:\(error)")
//                }
//            }
//        }.resume()
//    }
//}
import UIKit
import GoogleMaps

class ViewController: UIViewController {
   
   @IBOutlet weak var mapView: GMSMapView!
   
   override func viewDidLoad() {
       super.viewDidLoad()
       let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
       mapView.camera = camera

       addMarkersAndDrawPath()
   }

   func addMarkersAndDrawPath() {
       // Add origin marker
       let origin = CLLocationCoordinate2D(latitude: 24.871941, longitude: 66.988060)
       let markerOrigin = GMSMarker(position: origin)
       markerOrigin.title = "Origin"
       markerOrigin.map = mapView

       // Add destination marker
       let destination = CLLocationCoordinate2D(latitude: 24.885958, longitude: 67.026744)
       let markerDestination = GMSMarker(position: destination)
       markerDestination.title = "Destination"
       markerDestination.map = mapView

       // Draw a polyline
       let path = GMSMutablePath()
       path.add(origin)
       path.add(destination)
       let polyline = GMSPolyline(path: path)
       polyline.strokeWidth = 3.0
       polyline.map = mapView
   }
}


                                   

                        
