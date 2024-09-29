//
//  RouteOrTime.swift
//  Fast_Walk
//
//  Created by Tom  on 2024/07/18.
//

import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import GoogleSignIn
import LineSDK
import RealmSwift

class RouteOrTimeViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate{
    var titleLabel: UILabel!
    var currentLocation: CLLocationCoordinate2D?
//    @IBOutlet weak var mapContainerView: UIView!
//    var mapView: GMSMapView? //static throughout scope of entire program
//    var locationManager = CLLocationManager()
    @IBOutlet weak var profilePic: UIButton!
    var window: UIWindow?
    
//    @IBOutlet weak var timeButton: UIButton!
//    @IBOutlet weak var routeButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.definesPresentationContext = true

        profilePic.setImage(UIImage(named: "google.png"), for: .normal) // Make sure "default_profile_image" exists in your assets

        addTitleLabel()
        setupBackButton()
        addGradientLayer()
        setupProfilePicConstraints()

//        setupButtonsLayout()

        
        fetchGoogleUserInfo()
        fetchLineUserInfo()
//        profilePicFunc()
        
//        self.view.sendSubviewToBack(mapContainerView)
        self.view.bringSubviewToFront(profilePic)
    }
    
    
// ポップアップよう追加ーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーーー
    func showProfilePopup() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
//
//        // modalPresentationStyleをoverFullScreenに設定
//        profileVC.modalPresentationStyle = .overFullScreen
//        profileVC.modalTransitionStyle = .crossDissolve
//
//        self.present(profileVC, animated: true, completion: nil)

        
        let profileVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as! ProfileViewController
        addChild(profileVC)
        profileVC.view.frame = view.bounds
        view.addSubview(profileVC.view)
        profileVC.didMove(toParent: self)


//        // viewのフレームを画面全体に設定
//        profileVC.view.frame = self.view.bounds
//        
//        // ProfileViewControllerを子ビューとして追加
//        self.addChild(profileVC)
//        self.view.addSubview(profileVC.view)
//        profileVC.didMove(toParent: self)
//        
//        // アニメーションでポップアップを表示
//        profileVC.view.alpha = 0
//        UIView.animate(withDuration: 0.3) {
//            profileVC.view.alpha = 1
//            
//        }
    }


//    func profilePicFunc(){
//        profilePic.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            profilePic.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),  // Adjust as needed
//            profilePic.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),  // Adjust for spacing from the right
//            profilePic.widthAnchor.constraint(equalToConstant: 80),   // Set width
//            profilePic.heightAnchor.constraint(equalToConstant: 80)   // Set height to match width (circular icon)
//        ])
//        
//    }

//    func setupButtonsLayout() {
//        // Constraints for the timeButton (assuming center alignment and some top padding)
//        timeButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            timeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            timeButton.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 150), // Adjust the constant as per storyboard
//            timeButton.widthAnchor.constraint(equalToConstant: 200),  // Adjust width as per need
//            timeButton.heightAnchor.constraint(equalToConstant: 50)   // Adjust height as per need
//        ])
//        
//        // Constraints for the routeButton (just below timeButton)
//        routeButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            routeButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
//            routeButton.topAnchor.constraint(equalTo: timeButton.bottomAnchor, constant: 20),  // Adjust the constant for spacing between buttons
//            routeButton.widthAnchor.constraint(equalToConstant: 200),  // Adjust width as per need
//            routeButton.heightAnchor.constraint(equalToConstant: 50)   // Adjust height as per need
//        ])
//    }
    
    
    func setupProfilePicConstraints() {
        profilePic.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            profilePic.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),  // Adjust as needed
            profilePic.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -20),  // Adjust for spacing from the right
            profilePic.widthAnchor.constraint(equalToConstant: 50),   // Set width
            profilePic.heightAnchor.constraint(equalToConstant: 50)   // Set height to match width (circular icon)
        ])
        
        // Ensure the button is rounded (circular)
        profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }
    
    @IBAction func TimeButton(){
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         if let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController {
             mainNavController.modalPresentationStyle = .fullScreen
             self.present(mainNavController, animated: true, completion: nil)
         }
     }
    
    @IBAction func goToProfile() {
        let storyboard = UIStoryboard(name: "UserStoryboard", bundle: nil)
        if let profileNavController = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            profileNavController.modalPresentationStyle = .fullScreen
            self.present(profileNavController, animated: true, completion: nil)
        }
    }
     
     @IBAction func RouteButton(){
         let storyboard = UIStoryboard(name: "RouteStoryboard", bundle: nil)
         if let mainNavController = storyboard.instantiateViewController(withIdentifier: "RouteNavigationController") as? UINavigationController {
             mainNavController.modalPresentationStyle = .fullScreen
             self.present(mainNavController, animated: true, completion: nil)
         }
     }

    func fetchGoogleUserInfo() {
        if let user = GIDSignIn.sharedInstance.currentUser {
            // User is already signed in; proceed to fetch profile information
            updateProfileInfo(user: user)
        } else {
            print("User is not signed in.")
            window = UIWindow(frame: UIScreen.main.bounds)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as! LoginViewController
            loginVC.modalPresentationStyle = .fullScreen
            self.window?.rootViewController = loginVC
        }
    }
    
    func updateProfileInfo(user: GIDGoogleUser) {
        if let imageUrl = user.profile?.imageURL(withDimension: 60) {
            downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    self.profilePic.setImage(image, for: .normal)
                    self.profilePic.imageView?.contentMode = .scaleAspectFill
                    
                    // Ensure the button remains circular
                    self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
                    self.profilePic.clipsToBounds = true
                }
            }
        }
    }
    
    
    func fetchLineUserInfo() {
        API.getProfile { result in
            switch result {
            case .success(let profile):
                if let url = profile.pictureURL {
                    self.downloadImage(from: url) { image in
                        DispatchQueue.main.async {
                            // Set the image for the button's normal state
                            self.profilePic.setImage(image, for: .normal)
                            // Set the imageView's content mode
                            self.profilePic.imageView?.contentMode = .scaleAspectFill
                            // Apply corner radius to make it circular
                            self.profilePic.layer.cornerRadius = self.profilePic.frame.size.width / 2
                            self.profilePic.clipsToBounds = true
                        }
                    }
                }
            case .failure(let error):
                print("Error fetching LINE user info: \(error)")
            }
        }
    }
    
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        let urlNS = url as NSURL
        if let cachedImage = ImageCache.getImage(url: urlNS) {
            completion(cachedImage)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error downloading image: \(error)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to convert data to image.")
                completion(nil)
                return
            }
            
            ImageCache.setImage(url: urlNS, image: image)
            completion(image)
        }.resume()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
                super.viewDidAppear(animated)
                
                // Trigger the animation when the view appears
                animateTitleLabel()
            }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Ensure the button is round
        profilePic.layer.cornerRadius = profilePic.frame.size.width / 2
        profilePic.clipsToBounds = true
    }
    
    
//    func setupMapView() {
//        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 10.0)
//        mapView = GMSMapView.map(withFrame: mapContainerView.bounds, camera: camera)
//        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        
//        mapView?.delegate = self // Set the delegate after initializing the mapView
//        
//        mapContainerView.addSubview(mapView!)
//        beginLocationUpdate()
//    }
    
//    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
//        beginLocationUpdate()
//    }
//    
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.first, currentLocation == nil {
//            currentLocation = location.coordinate
//            updateMapCamera(location.coordinate)
//            mapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: 10.0)
//            mapView?.isMyLocationEnabled = true
//            mapView?.settings.myLocationButton = true
//            mapView?.settings.zoomGestures = true //allows for zoom
//            locationManager.stopUpdatingLocation() //why is this here? stop updating location
//        }
//    }
//    
//    func beginLocationUpdate() {
//        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
//            locationManager.startUpdatingLocation()
//        } else {
//            locationManager.requestWhenInUseAuthorization()
//        }
//    }
//    
//    func updateMapCamera(_ coordinate: CLLocationCoordinate2D) {
//        let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 20.0)
//        mapView?.animate(with: cameraUpdate)
//        mapView?.isMyLocationEnabled = true
//        mapView?.settings.myLocationButton = true
//    }
//        
        func addTitleLabel() {
            // Create the label
            titleLabel = UILabel()
            titleLabel.text = "さっさかコース選択"
            titleLabel.font = UIFont(name: "NotoSansJP-SemiBold", size: 30) // Noto Sans JP Medium font
            titleLabel.textColor = .black
            titleLabel.alpha = 0.0 // Initially set the label to be fully transparent (for the animation)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            // Add the label to the view
            self.view.addSubview(titleLabel)
            
            // Set constraints for the label (align to top and left)
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 50),
                titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 100)
            ])
            self.view.bringSubviewToFront(titleLabel)
        }
        
        func animateTitleLabel() {
            // Animate the label from blurry to clear
            UIView.animate(withDuration: 0.2, animations: {
                self.titleLabel.alpha = 0.8 // Fully visible after the animation
            })
        }
    func addGradientLayer() {
            // CAGradientLayer 생성
            let gradientLayer = CAGradientLayer()

            // 시작 색상: #B4E4FF, 100% 투명도
            let topColor = UIColor(red: 180/255, green: 228/255, blue: 255/255, alpha: 0.8).cgColor // #B4E4FF, 100% 투명
        
        // 중간 색상: 흰색, 75% 투명도
            let middleColor = UIColor(white: 1.0, alpha: 0.65).cgColor // 흰색 75% 투명도
        
            // 끝 색상: #D7F1FF, 25% 투명도
            let bottomColor = UIColor(red: 215/255, green: 241/255, blue: 255/255, alpha: 0.25).cgColor // #D7F1FF, 25% 투명

            // 그라데이션의 색상 배열 설정
            gradientLayer.colors = [topColor, middleColor, bottomColor]
        
        // 그라데이션의 각 색상이 적용될 위치 (0.0이 상단, 1.0이 하단)
           gradientLayer.locations = [0.0, 0.5, 1.0] // 중간 색상이 50% 위치에 오도록 설정

            // 그라데이션 레이어의 프레임 설정
            gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 140) // 높이 조절 가능

            // 그라데이션 위치 설정 (0.0이 상단, 1.0이 하단)
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 2.0)

            // view의 레이어에 그라데이션 레이어 추가
            self.view.layer.addSublayer(gradientLayer)
        }
        
        func setupBackButton(){
            let backButton = UIButton(type: .system)
            backButton.setImage(UIImage(named: "Backbutton.png"), for: .normal)
            backButton.tintColor = UIColor(red: 84/255.0, green: 84/255.0, blue: 84/255.0, alpha: 0.9)
            backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
            
            backButton.frame = CGRect(x: 20, y: 50, width: 22, height: 22)
            
            // Add the button to the view
            view.addSubview(backButton)
            view.bringSubviewToFront(backButton)
        }
        
        @objc func backButtonTapped() {
            print("button tapped")
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if let chooseVC = storyboard.instantiateViewController(withIdentifier: "WelcomeViewController") as? WelcomeViewController {
                chooseVC.modalPresentationStyle = .fullScreen
                self.present(chooseVC, animated: true, completion: nil)
            }
        }
    

    
    }
