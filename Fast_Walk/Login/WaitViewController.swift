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
        checkUserState()
    }
    
    func checkUserState() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        // Check if the user is logged in with Google
        if GIDSignIn.sharedInstance.currentUser != nil {
            print("User already signed in with Google")
            presentMainNavigationController()
            return
        }

        // Check if the user is logged in with LINE
        API.getProfile { [weak self] result in
            switch result {
            case .success(_):
                print("User logged in with LINE")
                self?.presentMainNavigationController()
            case .failure(_):
                print("User not logged in with LINE")
                self?.presentLoginViewController()
            }
        }
    }

    private func presentMainNavigationController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
            mainNavController.modalPresentationStyle = .fullScreen
            self.present(mainNavController, animated: true, completion: nil)
        }
    }

    private func presentLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginVC.modalPresentationStyle = .fullScreen
            self.present(loginVC, animated: true, completion: nil)
        }
    }
}
