//
//  ProfileViewController.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/26.
//

import UIKit
import RealmSwift
import GoogleSignIn
import LineSDK

class ProfileViewController: UIViewController {
    
    @IBOutlet var mail: UILabel!
    @IBOutlet var name: UILabel!
    @IBOutlet var favorites: UILabel!
    @IBOutlet var userIcon: UIImageView!
    @IBOutlet var method: UILabel!
    @IBOutlet var viewRound: UIView!
    
    var user: User = User()
    
    let realm = try! Realm()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("user is\(user)")
        method.text = "Google"
        mail.text = user.email
        name.text = user.name
        favorites.text = String(userFavorite())
        icon()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        viewRound.layer.cornerRadius = viewRound.frame.size.width / 10
    }
    
    @IBAction func heartViewController() {
        let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
        if let heartVC = storyboard.instantiateViewController(withIdentifier: "HeartViewController") as? HeartViewController {
            heartVC.modalPresentationStyle = .fullScreen
            self.present(heartVC, animated: true, completion: nil)
        }
    }
    @IBAction func home() {
        let storyboard = UIStoryboard(name: "RouteOrTime", bundle: nil)
        if let routeortimeVC = storyboard.instantiateViewController(withIdentifier: "RouteOrTimeViewController") as? RouteOrTimeViewController {
            routeortimeVC.modalPresentationStyle = .fullScreen
            self.present(routeortimeVC, animated: true, completion: nil)
        }
    }
    
    func icon() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            // User is already signed in; proceed to fetch profile information
            updateProfileInfo(user: user)
        }
    }
    
    func updateProfileInfo(user: GIDGoogleUser) {
        // Assuming you want the profile image URL
        if let imageUrl = user.profile?.imageURL(withDimension: 80) {
            downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    self.userIcon.image = image
                    self.userIcon.layer.cornerRadius = self.userIcon.frame.size.width / 2
                }
            }
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let urlNS = url as NSURL
        if let cachedImage = ImageCache.getImage(url: urlNS) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image.")
                completion(nil)
                return
            }
            
            ImageCache.setImage(url: urlNS, image: image)
            completion(image)
        }.resume()
    }
    
    func userFavorite() -> Int {
        var fav = Array(realm.objects(FavoriteSpot.self))
        var num = 0
        for fa in fav {
            if fa.userID == user.userID {
                num = num + 1
            }
        }
        return num
    }
    
    @IBAction func signOut(sender: Any) {
        GIDSignIn.sharedInstance.signOut()
        LoginManager.shared.logout { result in
            switch result {
            case .success:
                print("Logout from LINE")
            case .failure(let error):
                print(error)
            }
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
        loginVC.modalPresentationStyle = .fullScreen  // Ensuring it covers the full screen
        self.present(loginVC, animated: true, completion: nil)
    }
    
}
