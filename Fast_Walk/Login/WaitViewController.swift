//
//  WaitViewController.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/05.
//

import UIKit
import GoogleSignIn
import LineSDK

class WaitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userState()
        lineState()
    }
    
    func userState() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if GIDSignIn.sharedInstance.currentUser != nil {
            print("User already signed in")

            if let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
                mainNavController.modalPresentationStyle = .fullScreen
                self.present(mainNavController, animated: true, completion: nil)
            }
        }
        else {
            print("User not signed in")
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }
    
    func lineState() {
        if let _ = AccessTokenStore.shared.current {
            print("User is logged in with LINE")
            // User is logged in, proceed to main navigation controller
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
                mainNavController.modalPresentationStyle = .fullScreen
                self.present(mainNavController, animated: true, completion: nil)
            }
        } else {
            print("User is not logged in with LINE")
            // User is not logged in with LINE, show login view controller or perform other appropriate action
            // Optionally, you can redirect the user to the LoginViewController or stay on the current view
        }
    }
            
}
