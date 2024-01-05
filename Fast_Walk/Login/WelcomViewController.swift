//
//  WelcomViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/03.
//

import UIKit
import GoogleSignIn

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
        }
    }
    
    
    
    @IBAction func continueButton() {
        print("continue button pressed")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
            self.navigationController?.pushViewController(mainNavController.viewControllers.first!, animated: true)
        }
    }
}
