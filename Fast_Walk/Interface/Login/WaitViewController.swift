//
//  WaitViewController.swift
//  Fast_Walk
//
//  Created by visitor on 2024/01/05.
//

import UIKit
import GoogleSignIn
import LineSDK
import RealmSwift

class WaitViewController: UIViewController {
    
    var countdownTimer: Timer!
    var remainingSeconds = 3
    
    let realm = try! Realm()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setGradientBackground()
        addImageView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startCountdown()
    }
    
    func checkUserState() {
        _ = UIStoryboard(name: "Main", bundle: nil)
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                print("user not signed in with google")
                self.presentChooseViewController()
            } else if let token = AccessTokenStore.shared.current {
                print("user already logged in with Line" + token.value)
                self.presentRouteOrTimeViewController()
            }
            else if user != nil || error != nil {
                print("user previously signed in with google")
                //MARK: pass current User
                let id: String = user?.userID ?? "nil"
                self.currentClass(id)
                self.presentRouteOrTimeViewController()
            } else {
                print("present user to login viewcontroller")
                self.presentLoginViewController()
            }
        }
    }
    
    func currentClass(_ id: String) {
        let allUser = Array(realm.objects(User.self))
        for user in allUser {
            if user.userID == id {
                Current.user = user
            }
        }
    }
    
    private func presentRouteOrTimeViewController() {
        let storyboard = UIStoryboard(name: "RouteOrTime", bundle: nil)
        if let routeOrTimeViewController = storyboard.instantiateViewController(withIdentifier: "RouteOrTimeViewController") as? RouteOrTimeViewController {
            routeOrTimeViewController.modalPresentationStyle = .fullScreen
            self.present(routeOrTimeViewController, animated: false, completion: nil)
        } else {
            print("Failed to instantiate RouteOrTimeViewController")
        }
        print("going to route or time")
    }

    
    private func presentLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let loginViewController = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController {
            loginViewController.modalPresentationStyle = .fullScreen
            self.present(loginViewController, animated: false, completion: nil)
        }
    }

    private func presentChooseViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let chooseVC = storyboard.instantiateViewController(withIdentifier: "ChooseViewController") as? ChooseViewController {
            chooseVC.modalPresentationStyle = .fullScreen
            self.present(chooseVC, animated: false, completion: nil)
        }
    }
func addImageView() {
           let imageView = UIImageView()
           
           // Set the desired size for the image view
           let imageViewSize = CGSize(width: 67.0, height: 115.0)
           
           // Calculate the centered origin point for the resized image view
           let originX = (view.bounds.width - imageViewSize.width) / 2.0
    let originY = (view.bounds.height - imageViewSize.height) / 2.7
           
           imageView.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: imageViewSize)
           
           //imageView.frame = view.bounds
           imageView.contentMode = .scaleAspectFill
           imageView.image = UIImage(named: "sasaka logo megabig.png")
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
        print("startCountdown")
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
    }
    
    @objc func updateCountdown() {
        remainingSeconds -= 1
        print (remainingSeconds)
        if remainingSeconds == 0 {
            checkUserState()
            countdownTimer.invalidate()
        }
    }
    
}
