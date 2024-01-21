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
    
    var countdownTimer: Timer!
    var remainingSeconds = 3
    
    override func viewDidLoad() {
        super.viewDidLoad()
<<<<<<< HEAD

        // Call the functions to set up the gradient layer and add the image view
        setGradientBackground()
        addImageView()
=======
//        setGradientBackground()
>>>>>>> Develop
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCountdown()
    }
    
    func checkUserState() {
        _ = UIStoryboard(name: "Main", bundle: nil)
        
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

   
       func addImageView() {
           let imageView = UIImageView()
           
           // Set the desired size for the image view
           let imageViewSize = CGSize(width: 47.0, height: 77.0)
           
           // Calculate the centered origin point for the resized image view
           let originX = (view.bounds.width - imageViewSize.width) / 2.0
           let originY = (view.bounds.height - imageViewSize.height) / 2.5
           
           imageView.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: imageViewSize)
           
           //imageView.frame = view.bounds
           imageView.contentMode = .scaleAspectFill
           imageView.image = UIImage(named: "/Users/keeseojung/Documents/Fast_Walk/Fast_Walk/Assets/sasaka logo4.png")
           imageView.clipsToBounds = true // Add this line
           view.addSubview(imageView)
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
    
    func startCountdown() {
        print("startCountdo")
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown() {
        remainingSeconds -= 1
        print (remainingSeconds)
        if remainingSeconds <= 0 {
            countdownTimer.invalidate()
            checkUserState()
        }
    }
    
}
