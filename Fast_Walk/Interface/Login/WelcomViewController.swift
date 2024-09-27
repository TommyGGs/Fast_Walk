//
//  WelcomViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/03.
//

import UIKit
import GoogleSignIn
import LineSDK
import RealmSwift

class WelcomeViewController: UIViewController {
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var userIcon: UIImageView!
    
    let realm = try! Realm()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInformation()
        setGradientBackground()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let routeOrTimeVC = storyboard.instantiateViewController(withIdentifier: "RouteOrTimeViewController") as? RouteOrTimeViewController {
            routeOrTimeVC.modalPresentationStyle = .fullScreen
            self.present(routeOrTimeVC, animated: true, completion: nil)
        }
    }
    
    func fetchLineUserInfo() {
        API.getProfile { result in
            switch result {
            case .success(let profile):
                if let url = profile.pictureURL {
                    self.downloadImage(from: url) { image in
                        DispatchQueue.main.async {
                            self.userIcon.image = image
                            self.userIcon.layer.cornerRadius = self.userIcon.frame.size.width / 2
                            self.userIcon.clipsToBounds = true
                        }
                    }
                }
                self.updateWelcomeMessage(withName: profile.displayName)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func fetchGoogleUserInfo() {
        if let user = GIDSignIn.sharedInstance.currentUser, let imageUrl = user.profile?.imageURL(withDimension: 80) {
            downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    self.userIcon.image = image
                    self.userIcon.layer.cornerRadius = self.userIcon.frame.size.width / 2
                    self.userIcon.clipsToBounds = true
                }
            }
        }
    }

    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
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
            DispatchQueue.main.async {
                completion(image)
            }
        }.resume()
    }
    
    func userInformation() {
        if let user = GIDSignIn.sharedInstance.currentUser, let userName = user.profile?.name {
            updateWelcomeMessage(withName: userName)
            fetchGoogleUserInfo()
        } else {
            fetchLineUserInfo()
        }
    }

    func updateWelcomeMessage(withName name: String) {
        let fullText = "ようこそ、\(name) さん！"
        let boldPart = name
        let range = (fullText as NSString).range(of: boldPart)
        let attributedString = NSMutableAttributedString(string: fullText)
        attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: range)
        welcomeMessage.attributedText = attributedString
    }
  
    func setGradientBackground() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = view.bounds
        
        // Set your custom colors
        gradientLayer.colors = [
            UIColor(red: 0x45/255.0, green: 0xB1/255.0, blue: 0xFF/255.0, alpha: 1.0).cgColor,
            UIColor(red: 0x00/255.0, green: 0x21/255.0, blue: 0xCD/255.0, alpha: 1.0).cgColor
        ]

        // You can customize the direction of the gradient if needed
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.8)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)

        // Add the gradient layer to your view's layer
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
}
