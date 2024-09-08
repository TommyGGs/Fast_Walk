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
        
        
        func addGradientLayer() {
            // CAGradientLayer 생성
            let gradientLayer = CAGradientLayer()

            // 시작 색상: #B4E4FF, 100% 투명도
            let topColor = UIColor(red: 180/255, green: 228/255, blue: 255/255, alpha: 0.8).cgColor // #B4E4FF, 100% 투명
        
        // 중간 색상: 흰색, 75% 투명도
            let middleColor = UIColor(white: 1.0, alpha: 0.65).cgColor // 흰색 75% 투명도
        
            // 끝 색상: #D7F1FF, 25% 투명도
            let bottomColor = UIColor(red: 215/255, green: 241/255, blue: 255/255, alpha: 0.25).cgColor // #D7F1FF, 25% 투명

            // 그라데이션의 색상 배열 설정
            gradientLayer.colors = [topColor, middleColor, bottomColor]
        
        // 그라데이션의 각 색상이 적용될 위치 (0.0이 상단, 1.0이 하단)
           gradientLayer.locations = [0.0, 0.5, 1.0] // 중간 색상이 50% 위치에 오도록 설정

            // 그라데이션 레이어의 프레임 설정
            gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140) // 높이 조절 가능

            // 그라데이션 위치 설정 (0.0이 상단, 1.0이 하단)
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 2.0)

            // view의 레이어에 그라데이션 레이어 추가
            self.view.layer.addSublayer(gradientLayer)
        }


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
