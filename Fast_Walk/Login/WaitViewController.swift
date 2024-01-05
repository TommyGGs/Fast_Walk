//
//  WaitViewController.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/05.
//

import UIKit
import GoogleSignIn

class WaitViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userState()
    }
    
    func userState() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        if GIDSignIn.sharedInstance.currentUser != nil {
            print("User already signed in")

            if let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
                mainNavController.modalPresentationStyle = .fullScreen
                self.present(mainNavController, animated: true, completion: nil)
            }
        } else {
            print("User not signed in")
            if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
                loginVC.modalPresentationStyle = .fullScreen
                self.present(loginVC, animated: true, completion: nil)
            }
        }
    }
}
