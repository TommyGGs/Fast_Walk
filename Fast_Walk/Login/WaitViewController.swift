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
        setGradientBackground()
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
                self?.presentChooseViewController()
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

    private func presentChooseViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chooseVC = storyboard.instantiateViewController(withIdentifier: "ChooseViewController") as? ChooseViewController {
            chooseVC.modalPresentationStyle = .fullScreen
            self.present(chooseVC, animated: true, completion: nil)
        }
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
