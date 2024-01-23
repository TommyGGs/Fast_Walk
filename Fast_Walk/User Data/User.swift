//
//  User.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/19.
//

import Foundation
import RealmSwift
import CoreLocation

class User: Object {
    @Persisted var email: String = ""
    @Persisted var signinMethod: String = ""
    @Persisted var userID: String = ""
    @Persisted var name: String = ""
}

class FavoriteSpot: Object {
    @Persisted var userName: String = ""
    @Persisted var userID: String = ""
    @Persisted var latitude: Double
    @Persisted var longitude: Double
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    convenience init(coordinate: CLLocationCoordinate2D) {
        self.init()
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

