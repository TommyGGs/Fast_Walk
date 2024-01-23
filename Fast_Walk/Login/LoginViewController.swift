//
//  LoginViewController.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/01/02.
//

import UIKit
import GoogleSignIn
import LineSDK
import RealmSwift

class LoginViewController: UIViewController, LoginButtonDelegate {
    
    var users: [User] = []
    var userExist: Bool = false
    let realm = try! Realm()


    override func viewDidLoad() {
        super.viewDidLoad()
        users = readUsers()
        rectangleView()
        lineButton()
        setGradientBackground()
    }

    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        userGoogleState()
    }
    
    func lineButton() {
        // Create a custom button for LINE login
        let customLineButton = UIButton(type: .custom)
        customLineButton.setTitle("LINEでログイン", for: .normal) // Set the text
        
        // Set the custom font
               if let customFont = UIFont(name: "NotoSansJP-Regular", size: 16.0) {
                   customLineButton.titleLabel?.font = customFont
               } else {
                   print("Font not available")
               }
        
        // Add button to view and layout it
        view.addSubview(customLineButton)
        customLineButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            customLineButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customLineButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -10), // Moves the button higher up
            customLineButton.widthAnchor.constraint(equalToConstant: 240), // Wider button
            customLineButton.heightAnchor.constraint(equalToConstant: 45) // Taller button
        ])
        
        // Set the images for different button states after adding the button to the view
        if let image = UIImage(named: "btn_login_base") {
            // Adjust these insets to match the thin edge you want to stretch.
            let rightStretchWidth: CGFloat = 5.0 // The thin edge on the left side to be stretched
            let capInsets = UIEdgeInsets(
                top: 0,
                left: image.size.width - rightStretchWidth - 1,
                bottom: 0,
                right: rightStretchWidth // Leave 1 pixel of the right side unstretched
            )
            
            let resizableImage = image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
            customLineButton.setBackgroundImage(resizableImage, for: .normal)
        }
        
        if let image = UIImage(named: "btn_login_pressed") {
            // Adjust these insets to match the thin edge you want to stretch.
            let rightStretchWidth: CGFloat = 5.0 // The thin edge on the left side to be stretched
            let capInsets = UIEdgeInsets(
                top: 0,
                left: image.size.width - rightStretchWidth - 1,
                bottom: 0,
                right: rightStretchWidth // Leave 1 pixel of the right side unstretched
            )
            
            let resizableImage = image.resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
            customLineButton.setBackgroundImage(resizableImage, for: .normal)
        }
        
        customLineButton.addTarget(self, action: #selector(loginWithLine), for: .touchUpInside)
    }
    
    func rectangleView() {
        // Create a UIView for the rectangle
        let rectangleView = UIView()

        // Set the frame for the rectangle (adjust the values as needed)
        let rectangleFrame = CGRect(x: 20, y: 270, width: 350, height: 220)
        rectangleView.frame = rectangleFrame

        // Set the corner radius for rounded corners
        rectangleView.layer.cornerRadius = 18

        // Set the background color to clear (no filled color)
        rectangleView.backgroundColor = UIColor.clear

        // Set the border color (E8E8E8 with 39% transparency)
        rectangleView.layer.borderColor = UIColor(red: 0xE8/255.0, green: 0xE8/255.0, blue: 0xE8/255.0, alpha: 0.39).cgColor

        // Set the border width
        rectangleView.layer.borderWidth = 1.0

        // Add the rectangle to the view
        view.insertSubview(rectangleView, at: 0)
    }
    
    func userGoogleState() {
        if let signInResult = GIDSignIn.sharedInstance.currentUser {
            print("User already signed in")
            for user in users {
                if user.userID == signInResult.userID {
                    print("google user already exist")
                    userExist = true
                } else {
                    print("User not signed in")
                    userExist = false
                }
            }
        }
    }
    
    func readUsers() -> [User] {
        return Array(realm.objects(User.self))
    }
    
    @objc func loginWithLine() {
        LoginManager.shared.login(permissions: [.profile], in: self) {
            result in
            switch result {
            case .success(let loginResult):
                if let profile = loginResult.userProfile {
                    
                    for user in self.users {
                        if user.userID == profile.userID {
                            self.userExist = true
                            print("user already exist")
                            return
                        }
                    }
                    if self.userExist == false {
                      let user = User()
                        user.email = ""
                        user.name = profile.displayName
                        user.signinMethod = "Line"
                        user.userID = profile.userID
                        print("trying to create Line user")
                        self.createUser(user: user)
                    }
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let welcomeVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as! WelcomeViewController
                    welcomeVC.modalPresentationStyle = .fullScreen
                    self.present(welcomeVC, animated: true, completion: nil)
                }
            case .failure(let error):
                print(error)
            }
        }

    }
    
    
    func createUser(user: User) {
        try! realm.write{
            realm.add(user)
            print("user create succeeded")
        }
    }


    
    @IBAction func signIn(sender: Any) {
        print("clicked google signin")
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { signInResult, error in
            guard error == nil else {
                print("Error logging in: \(error?.localizedDescription ?? "")")
                return
            }
            if signInResult != nil {
                if self.userExist == false {
                    self.saveGoogleUser()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let welcomeVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                        welcomeVC.modalPresentationStyle = .fullScreen
                        self.present(welcomeVC, animated: true, completion: nil)
                    } else {
                        print("Could not instantiate WelcomeViewController from storyboard.")
                    }
                } else if self.userExist == true {
                    print("this google user exists taking to main screen")
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
                        mainNavController.modalPresentationStyle = .fullScreen
                        self.present(mainNavController, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    func saveGoogleUser() {
        if let googleSign = GIDSignIn.sharedInstance.currentUser {
            let userGoogle = User()
            if let email = googleSign.profile?.email,
               let name = googleSign.profile?.name,
               let userID = googleSign.userID {
                userGoogle.email = email
                userGoogle.name = name
                userGoogle.userID = userID
                self.createUser(user: userGoogle)
            }
        }
    }

}


extension LoginViewController {
    func loginButton(_ button: LoginButton, didSucceedLogin loginResult: LoginResult) {
        print("Login Succeeded.")
        // Navigate to next screen or handle login result
    }

    func loginButton(_ button: LoginButton, didFailLogin error: LineSDKError) {
        print("Error: \(error)")
        // Handle error
    }

    func loginButtonDidStartLogin(_ button: LoginButton) {
        print("Login Started.")
        // Optionally show loading indicator
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
