//
//  RouteDetails.swift
//  Fast_Walk
//
//  Created by visitor on 2023/12/21.
//

import Foundation
import CoreLocation

struct RouteDetails {
    var polyString: String
    var durationText: String
    var startCoordinate: CLLocationCoordinate2D
    
}

struct PlaceInfo {
    var coordinate: CLLocationCoordinate2D
    var name: String
}
