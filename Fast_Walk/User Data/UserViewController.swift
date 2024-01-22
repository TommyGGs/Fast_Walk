//
//  FavoriteViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/20.
//

import UIKit
import RealmSwift
import GoogleSignIn
import LineSDK

class UserViewController: UIViewController, UITableViewDataSource {
    @IBOutlet var tableView: UITableView!
    
    var users: [User] = []
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.register(UINib(nibName: "UserTableViewCell", bundle: nil), forCellReuseIdentifier: "UserCell")
        users = readUsers()
    }
    
    func readUsers() -> [User] {
        return Array(realm.objects(User.self))
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as! UserTableViewCell
        let user: User = users[indexPath.row]
        cell.setCell(email: user.email, method: user.signinMethod, id: user.userID)
        
        return cell
    }
    
}
