//
//  LoginViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/02.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userState()
    }

    
    @IBAction func signIn(sender: Any) {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else {
                print("Error logging in: \(error?.localizedDescription ?? "")")
                return
            }

            if signInResult != nil {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if let welcomeVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                    welcomeVC.modalPresentationStyle = .fullScreen
                    self.present(welcomeVC, animated: true, completion: nil)
                } else {
                    print("Could not instantiate WelcomeViewController from storyboard.")
                }
            }
        }
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
            // Additional code if needed for when the user is not signed in
        }
    }

}
