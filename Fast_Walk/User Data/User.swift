//
//  User.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/19.
//

import Foundation
import RealmSwift

class User: Object {
    @Persisted var email: String = ""
    @Persisted var signinMethod: String = ""
    @Persisted var userID: String = ""
    @Persisted var name: String = ""
}

class FavoriteSpot: Object {
    @Persisted var userName: String = ""
    @Persisted var userID: String = ""
    @Persisted var xCoordinate: String = ""
    @Persisted var yCoordinate: String = ""
}
