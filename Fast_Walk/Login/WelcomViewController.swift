//
//  WelcomViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/03.
//

import UIKit
import GoogleSignIn
import LineSDK

class WelcomeViewController: UIViewController {
    @IBOutlet weak var welcomeMessage: UILabel!
    @IBOutlet weak var userIcon: UIImageView!
    
    var window: UIWindow?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userInformation()
    }
    
    func userInformation() {
        print("printing welcome image")
        if let user = GIDSignIn.sharedInstance.currentUser, let userName = user.profile?.name {
            let fullText = "ようこそ、\(userName) さん！"
            print(fullText)
            let boldPart = userName
            
            // Create a range for the bold part
            let range = (fullText as NSString).range(of: boldPart)
            
            // Create a mutable attributed string with the full text
            let attributedString = NSMutableAttributedString(string: fullText)
            
            // Set the font and any other attributes for the bold part
            attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: range)
            
            // Assign the attributed string to your label
            welcomeMessage.attributedText = attributedString
        } else {
            API.getProfile { result in
                switch result {
                case .success(let profile):
                    print("User ID: \(profile.userID)")
                    print("User Display Name: \(profile.displayName)")
                    print("User Status Message: \(profile.statusMessage)")
                    print("User Icon: \(String(describing: profile.pictureURL))")
                    
                    let fullText = "ようこそ、\(profile.displayName) さん！"
                    print(fullText)
                    let boldPart = profile.displayName
                    
                    // Create a range for the bold part
                    let range = (fullText as NSString).range(of: boldPart)
                    
                    // Create a mutable attributed string with the full text
                    let attributedString = NSMutableAttributedString(string: fullText)
                    
                    // Set the font and any other attributes for the bold part
                    attributedString.addAttribute(.font, value: UIFont.boldSystemFont(ofSize: 17), range: range)
                    
                    // Assign the attributed string to your label
                    self.welcomeMessage.attributedText = attributedString
                case .failure(let error):
                    print(error)
                }
            }

        }
    }
}
