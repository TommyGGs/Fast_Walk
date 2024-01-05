//
//  LoginViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/02.
//

import UIKit
import GoogleSignIn

class LoginViewController: UIViewController {
    
    var window: UIWindow?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
}
