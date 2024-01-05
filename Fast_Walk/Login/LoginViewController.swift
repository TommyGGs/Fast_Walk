//
//  LoginViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/02.
//

import UIKit
import GoogleSignIn
import AuthenticationServices

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
          guard error == nil else { print("error logging in");return }
       if signInResult != nil {
           let storyboard = UIStoryboard(name: "Main", bundle: nil)
           let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as! UINavigationController
           mainNavController.modalPresentationStyle = .fullScreen
           self.present(mainNavController, animated: false, completion: nil)
       }
      }
    }
}
