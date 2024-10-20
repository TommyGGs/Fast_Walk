import UIKit
import GoogleMaps
import CoreLocation
import GooglePlaces
import GoogleSignIn
import LineSDK
import RealmSwift



class ViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var profilePic: UIButton!
    @IBOutlet weak var navigationView: UIView!
    @IBOutlet weak var button30: UIButton!
    @IBOutlet weak var button45: UIButton!
    @IBOutlet weak var button60: UIButton!
    @IBOutlet weak var button90: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet var heartButton: UIButton!
    @IBOutlet var homeButton: UIButton!
    @IBOutlet var dataButton: UIButton!
    @IBOutlet var accountButton: UIButton!
    
    @IBOutlet weak var typeChoiceButton: UIButton!
    var placeTypes: [String] {
        return PlaceTypesList.placeTypes
    }
    var chosenType: String = "restaurant"
    @IBOutlet var heart: UIButton!
    
    var titleLabel: UILabel!
    var locationManager = CLLocationManager()
    var mapView: GMSMapView? //static throughout scope of entire program
    var currentLocation: CLLocationCoordinate2D?
    var selectedRouteDetails: RouteDetails?
    var currentRoutePolyline: GMSPolyline?
    var storedRouteDetails: RouteDetails?
    var marker = Marker()
    let randomwaypoint = randomWayPoint()
    var window: UIWindow?
    var passWaypoint: [GMSPlace] = []
    
    let realm = try! Realm()
    let customTransitioningDelegate = CustomTransitioningDelegate()
    
    var errorLabelReference: UILabel?

    
//MARK: スポット種類の選択
    let typeStackView = UIStackView()
    let shoppingButton = UIButton()
    let gourmetButton = UIButton()
    let natureButton = UIButton()
    let tourismButton = UIButton()
    
    
    private var placesClient: GMSPlacesClient! //For Places marker
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMapView()
        
        placesClient = GMSPlacesClient.shared() //Places
        typeChoiceButton.isHidden = true
        locationManager.delegate = self
        beginLocationUpdate()
        
        fetchGoogleUserInfo()
        fetchLineUserInfo()
        print("passed")
        setupStyle()
        setupChoiceButton()
        //        changeRouteButton()
//        navBar()
        //MARK: Setup route type selection view
        //        configurePlaceTypesStackView()
        //
        self.view.bringSubviewToFront(heartButton)
        self.view.bringSubviewToFront(homeButton)
        self.view.bringSubviewToFront(dataButton)
        self.view.bringSubviewToFront(accountButton)
        self.view.sendSubviewToBack(mapContainerView)
        
        Setuptoprectangularbox()
        addGradientLayer()
        addTitleLabel()
        setupBackButton()
        
        configurePlaceTypesButtons()

        
    }
    
    override func viewDidAppear(_ animated: Bool) {
            super.viewDidAppear(animated)
            
            // Trigger the animation when the view appears
            animateTitleLabel()
        }
    
    func addTitleLabel() {
           // Create the label
           titleLabel = UILabel()
           titleLabel.text = "タイムコース"
           titleLabel.font = UIFont(name: "NotoSansJP-Medium", size: 28) // Noto Sans JP Medium font
           titleLabel.textColor = .black
           titleLabel.alpha = 0.0 // Initially set the label to be fully transparent (for the animation)
           titleLabel.translatesAutoresizingMaskIntoConstraints = false
           
           // Add the label to the view
           self.view.addSubview(titleLabel)
           
           // Set constraints for the label (align to top and left)
           NSLayoutConstraint.activate([
               titleLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
               titleLabel.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 32)
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
            gradientLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 150) // 높이 조절 가능

            // 그라데이션 위치 설정 (0.0이 상단, 1.0이 하단)
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

            // view의 레이어에 그라데이션 레이어 추가
            self.view.layer.addSublayer(gradientLayer)
        }
    
    func setupBackButton(){
        let backButton = UIButton(type: .system)
        backButton.setImage(UIImage(named: "Backbutton.png"), for: .normal)
        backButton.tintColor = UIColor(red: 84/255.0, green: 84/255.0, blue: 84/255.0, alpha: 0.9)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        backButton.frame = CGRect(x: 20, y: 57, width: 22, height: 22)

        // Add the button to the vie
        view.addSubview(backButton)
        view.bringSubviewToFront(backButton)
    }
    
    @objc func backButtonTapped() {
        print("button tapped")
        let storyboard = UIStoryboard(name: "RouteOrTime", bundle: nil)
        if let chooseVC = storyboard.instantiateViewController(withIdentifier: "RouteOrTimeViewController") as? RouteOrTimeViewController {
            chooseVC.modalPresentationStyle = .fullScreen
            self.present(chooseVC, animated: false, completion: nil)
        }
    }

    @objc func heartView() {
        print("heart clicked")
        let storyboard = UIStoryboard(name: "Favorite", bundle: nil)
        if let heartVC = storyboard.instantiateViewController(withIdentifier: "HeartViewController") as? HeartViewController {
            heartVC.modalPresentationStyle = .custom
            heartVC.transitioningDelegate = customTransitioningDelegate
            self.present(heartVC, animated: false, completion: nil)
        }
    }
    
    private func configurePlaceTypesButtons() {
        let titles = ["ショップ","グルメ","自然","観光"]
        
        let barBackgroundView = UIView()
            barBackgroundView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
            barBackgroundView.layer.cornerRadius = 10
            barBackgroundView.layer.shadowColor = UIColor.black.cgColor
            barBackgroundView.layer.shadowOpacity = 0.1
        
        //gpt ch
            barBackgroundView.layer.shadowOffset = CGSize(width: 0, height: 1)
            barBackgroundView.layer.shadowRadius = 5
        
        view.addSubview(barBackgroundView)
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            stackView.spacing = 1
        
        
        for title in titles {
                let button = UIButton()
                setupButton(button, title: title)
                stackView.addArrangedSubview(button)
                
                // Associate button with the corresponding action
                button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
                
                // Set up tags or identifiers if necessary
                button.tag = titles.firstIndex(of: title) ?? 0
            }
        
        barBackgroundView.addSubview(stackView)
        
        barBackgroundView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                barBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
                barBackgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                barBackgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                barBackgroundView.heightAnchor.constraint(equalToConstant: 24)
            ])

        
        // Add the stack view to the view hierarchy
            view.addSubview(stackView)
            
            // Set constraints for the stack view
            stackView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 90),
                stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
                stackView.heightAnchor.constraint(equalToConstant: 34)
            ])
        }

        private func setupButton(_ button: UIButton, title: String) {
            button.setTitle(title, for: .normal)
            button.backgroundColor = UIColor(red: 217/255, green: 229/255, blue: 255/255, alpha: 1.0)
            button.setTitleColor(.darkGray, for: .normal)
            button.setTitleColor(.white, for: .selected)
            
            // Set the selected background color
            let selectedColor = UIColor(red: 79/255, green: 134/255, blue: 255/255, alpha: 1.0)
            button.setBackgroundImage(imageWithColor(color: selectedColor), for: .selected)
            
            button.layer.cornerRadius = 10
            button.clipsToBounds = true
            button.layer.borderWidth = 3
            button.layer.borderColor = CGColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        }

        @objc func buttonTapped(_ sender: UIButton) {
            // Deselect all buttons in the stack view
            if let stackView = sender.superview as? UIStackView {
                for case let button as UIButton in stackView.arrangedSubviews {
                    button.isSelected = false
                    button.backgroundColor = UIColor(red: 217/255, green: 229/255, blue: 255/255, alpha: 1.0)
                    button.setTitleColor(.darkGray, for: .normal)
                }
            }
            
            // Select the tapped button
            sender.isSelected = true
            sender.backgroundColor = UIColor(red: 79/255, green: 134/255, blue: 255/255, alpha: 1.0)
            sender.setTitleColor(.white, for: .normal)
            
            // Handle button tap by changing the chosen type
            switch sender.tag {
            case 0:
                self.chosenType = "clothing_store"
                print("shopping")
            case 1:
                self.chosenType = "restaurant"
                print("gourmet")
            case 2:
                self.chosenType = "park"
                print("nature")
            case 3:
                self.chosenType = "tourist_attraction"
                print("tourism")
            default:
                break
            }
        }
    
        private func imageWithColor(color: UIColor) -> UIImage {
            let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
            UIGraphicsBeginImageContext(rect.size)
            let context = UIGraphicsGetCurrentContext()
            context!.setFillColor(color.cgColor)
            context!.fill(rect)
            let img = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return img!
        }
    
    private func Setuptoprectangularbox(){
        let topboxview = UIView()
        topboxview.backgroundColor = UIColor.white
        topboxview.layer.cornerRadius = 5
        
        view.addSubview(topboxview)
        
        //gpt changed here
//        if let index = view.subviews.firstIndex(of: topboxview), index > 0 {
//            view.exchangeSubview(at: index, withSubviewAt: index - 1)
//        }

        
        topboxview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            topboxview.topAnchor.constraint(equalTo: view.topAnchor, constant: 0), // Adjust to 0 to stick to top
            topboxview.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0), // No padding
            topboxview.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0), // No padding
            topboxview.heightAnchor.constraint(equalToConstant: 150) // Adjust height as needed
        ])
    }
    
        //
//        setupButton(shoppingButton, title: "ショップ")
//        setupButton(gourmetButton, title: "グルメ")
//        setupButton(natureButton, title: "自然")
//        setupButton(tourismButton, title: "観光")
//        
//        let buttons = [shoppingButton, gourmetButton, natureButton, tourismButton]
//        for button in buttons {
//            view.addSubview(button)
//            button.translatesAutoresizingMaskIntoConstraints = false
//        }
//        let topAnchor = view.safeAreaLayoutGuide.topAnchor
//        let constant: CGFloat = 48
//        let height: CGFloat = 40
//        NSLayoutConstraint.activate([
//            shoppingButton.topAnchor.constraint(equalTo: topAnchor, constant: constant),
//            shoppingButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 3),
//            shoppingButton.heightAnchor.constraint(equalToConstant: height),
//            
//            gourmetButton.topAnchor.constraint(equalTo: topAnchor, constant: constant),
//            gourmetButton.leadingAnchor.constraint(equalTo: shoppingButton.trailingAnchor, constant: 3),
//            gourmetButton.widthAnchor.constraint(equalTo: shoppingButton.widthAnchor),
//            gourmetButton.heightAnchor.constraint(equalToConstant: height),
//            natureButton.topAnchor.constraint(equalTo: topAnchor, constant: constant),
//            natureButton.leadingAnchor.constraint(equalTo: gourmetButton.trailingAnchor, constant: 3),
//            natureButton.widthAnchor.constraint(equalTo: gourmetButton.widthAnchor),
//            natureButton.heightAnchor.constraint(equalToConstant: height),
//            tourismButton.topAnchor.constraint(equalTo: topAnchor, constant: constant),
//            tourismButton.leadingAnchor.constraint(equalTo: natureButton.trailingAnchor, constant: 3),
//            tourismButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -5),
//            tourismButton.widthAnchor.constraint(equalTo: natureButton.widthAnchor),
//            tourismButton.heightAnchor.constraint(equalToConstant: height),
//        ])
//    }
//    
//    private func setupButton(_ button: UIButton, title: String) {
//        button.setTitle(title, for: .normal)
//        button.backgroundColor = #colorLiteral(red: 0.8901962042, green: 0.8901962042, blue: 0.8901962042, alpha: 1) // Normal state color
//        button.setTitleColor(.black, for: .normal) // Adjust as needed
//        button.setTitleColor(.black, for: .selected)
//        let color = #colorLiteral(red: 0.7861115336, green: 0.846778214, blue: 0.9931553006, alpha: 1)
//        // Set a different color for the selected state
//        button.setBackgroundImage(imageWithColor(color: color), for: .selected)
//        
//        button.layer.cornerRadius = 10  // Adjust the corner radius as needed
//        button.clipsToBounds = true
//        button.layer.borderWidth = 3
//        button.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.4090455762)
//        button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
//    }
//    
//    private func imageWithColor(color: UIColor) -> UIImage {
//        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
//        UIGraphicsBeginImageContext(rect.size)
//        let context = UIGraphicsGetCurrentContext()
//        context!.setFillColor(color.cgColor)
//        context!.fill(rect)
//        let img = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        return img!
//    }
//    
//    @objc func buttonTapped(_ sender: UIButton) {
//        let buttons = [shoppingButton, gourmetButton, natureButton, tourismButton]
//        for button in buttons {
//            button.isSelected = false
//        }
//        sender.isSelected = true
//        //        DispatchQueue.main.async{
//        //            sender.backgroundColor = .darkGray
//        //            sender.setTitleColor(.white, for: .selected)
//        //        }
//        
//        
//        switch sender {
//        case shoppingButton:
//            self.chosenType = "clothing_store"
//            print ("shopping")
//        case gourmetButton:
//            self.chosenType = "restaurant"
//            print ("gourmet")
//        case natureButton:
//            self.chosenType = "park"
//            print ("park")
//        case tourismButton:
//            self.chosenType = "tourist_attraction"
//            print ("tourist")
//        default:
//            break
//        }
//    }
    //バーのコード
    func navBar() {
        
        // Create a control bar
        let controlBar = UIView()
        controlBar.backgroundColor = UIColor(red: 204/255, green: 217/255, blue: 245/255, alpha: 0.34)
        controlBar.layer.cornerRadius = 20 // Adjust the corner radius as needed
        view.addSubview(controlBar)
        
        // Add constraints to set the control bar's position and size
        controlBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            controlBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            controlBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            controlBar.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5), // Move lower
            controlBar.heightAnchor.constraint(equalToConstant: 60) //ここでバーの高さ変更（大きい数＝した）
        ])
        
        // Add image buttons to the control bar
        controlBar.addSubview(heartButton)
        controlBar.addSubview(homeButton)
        controlBar.addSubview(dataButton)
        controlBar.addSubview(accountButton)
        
        // Add constraints to position the image buttons within the control bar
        let buttonWidth = (view.frame.width - 40) / 4 // Adjust spacing as needed
        let buttonHeight: CGFloat = 30 //ここでボタンの高さ変えて（小さい数=もっと高く）
        
        heartButton.translatesAutoresizingMaskIntoConstraints = false
        heartButton.addTarget(self, action: #selector(heartView), for: .touchUpInside)
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        dataButton.translatesAutoresizingMaskIntoConstraints = false
        accountButton.translatesAutoresizingMaskIntoConstraints = false
        accountButton.addTarget(self, action: #selector(accountView), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            heartButton.leadingAnchor.constraint(equalTo: controlBar.leadingAnchor, constant: 10),
            heartButton.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 10), // Adjust the top anchor
            heartButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            heartButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            homeButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: 10),
            homeButton.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 10), // Adjust the top anchor
            homeButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            homeButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            dataButton.leadingAnchor.constraint(equalTo: homeButton.trailingAnchor, constant: 10),
            dataButton.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 10), // Adjust the top anchor
            dataButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            dataButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            accountButton.leadingAnchor.constraint(equalTo: dataButton.trailingAnchor, constant: 10),
            accountButton.topAnchor.constraint(equalTo: controlBar.topAnchor, constant: 10), // Adjust the top anchor
            accountButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            accountButton.heightAnchor.constraint(equalToConstant: buttonHeight),
            
            // Add trailing constraint to the last button
            accountButton.trailingAnchor.constraint(equalTo: controlBar.trailingAnchor, constant: -10),
        ])
        
        // Set button color to black
        heartButton.tintColor = UIColor.black
        homeButton.tintColor = UIColor.black
        dataButton.tintColor = UIColor.black
        accountButton.tintColor = UIColor.black
        
        let heartLabel = createLabel("お気に入り", fontSize: 10)
        let homeLabel = createLabel("ホーム", fontSize: 10)
        let dataLabel = createLabel("記録", fontSize: 10)
        let accountLabel = createLabel("アカウント", fontSize: 10)
        
        controlBar.addSubview(heartLabel)
        controlBar.addSubview(homeLabel)
        controlBar.addSubview(dataLabel)
        controlBar.addSubview(accountLabel)
        
        NSLayoutConstraint.activate([
            heartLabel.topAnchor.constraint(equalTo: heartButton.bottomAnchor, constant: 2),
            heartLabel.centerXAnchor.constraint(equalTo: heartButton.centerXAnchor),
            
            homeLabel.topAnchor.constraint(equalTo: homeButton.bottomAnchor, constant: 2),
            homeLabel.centerXAnchor.constraint(equalTo: homeButton.centerXAnchor),
            
            dataLabel.topAnchor.constraint(equalTo: dataButton.bottomAnchor, constant: 2),
            dataLabel.centerXAnchor.constraint(equalTo: dataButton.centerXAnchor),
            
            accountLabel.topAnchor.constraint(equalTo: accountButton.bottomAnchor, constant: 2),
            accountLabel.centerXAnchor.constraint(equalTo: accountButton.centerXAnchor),
        ])
    }
    
    @objc func accountView() {
        print("account clicked")
        let storyboard = UIStoryboard(name: "UserStoryboard", bundle: nil)
        if let accountVC = storyboard.instantiateViewController(withIdentifier: "ProfileViewController") as? ProfileViewController {
            accountVC.user = findUser()
            accountVC.modalPresentationStyle = .fullScreen
            accountVC.transitioningDelegate = customTransitioningDelegate
            self.present(accountVC, animated: false, completion: nil)
        }
    }
    
    func findUser() -> User {
        var allUsers = Array(realm.objects(User.self))
        
        for allUser in allUsers {
            if allUser.userID == checkUser() {
                return allUser
            }
        }
        return allUsers[0]
    }
    
    
    func checkUser() -> String {
        print("checking user function")
        if let profile = GIDSignIn.sharedInstance.currentUser, let profileID = profile.userID {
            print("google user id\(String(describing: profile.userID))")
            return profile.userID ?? "error"
        } else {
            print("error in GID")
            var profileID: String = ""
            API.getProfile { result in
                switch result {
                case .success(let profile):
                profileID = profile.userID
                case .failure(let error):
                    print(error)
                print("can't find line user as well")
                }
            }
            print("line user id\(profileID)")
            return profileID
        }
    }
    
    
    //コース変更
//    func changeRouteButton(){
//        let courseChangeButton = UIButton(type: .system)
//        courseChangeButton.setTitle("コース変更", for: .normal)
//        courseChangeButton.backgroundColor = UIColor(white: 1.0, alpha: 0.7)
//        courseChangeButton.layer.cornerRadius = 8
//        courseChangeButton.setTitleColor(UIColor.black, for: .normal)
//        
//        view.addSubview(courseChangeButton)
//        
//        courseChangeButton.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            courseChangeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            courseChangeButton.topAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
//            courseChangeButton.widthAnchor.constraint(equalToConstant: 130),
//            courseChangeButton.heightAnchor.constraint(equalToConstant: 50)
//        ])
////        
////        courseChangeButton.addTarget(self, action: #selector(courseChangeButtonTapped), for: .touchUpInside)
//        
//        
//        view.backgroundColor = UIColor.white // Replace with your desired color
//        
//        let yOffset: CGFloat = 50
//        let squareView = UIView(frame: CGRect(x: 0, y:  mapContainerView.bounds.height, width: view.bounds.width, height: 100))
//        squareView.layer.cornerRadius = 10
//        squareView.clipsToBounds = true
//        
//        // Create a gradient layer
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.frame = squareView.bounds
//        gradientLayer.colors = [UIColor.white.cgColor, UIColor.clear.cgColor]
//        gradientLayer.locations = [0.8, 3.0] // Adjust the locations to control the fading
//        
//        // Adjust startPoint and endPoint to make the gradient upside down
//        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1)
//        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0)
//        
//        // Add the gradient layer to the square view's layer
//        squareView.layer.addSublayer(gradientLayer)
//        
//        // Add the square view to the main view
//        view.addSubview(squareView)
//        
//        // Move the square view to the back of the view hierarchy
//        view.sendSubviewToBack(squareView)
//        
//        
//        
//    }
//    
//    @objc func courseChangeButtonTapped() {
//        print("コース変更 button tapped")
//        // Implement your action for the button tap here
//        
//        
//        
//        
//    }
    
    func setupMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 0, longitude: 0, zoom: 10.0)
        mapView = GMSMapView.map(withFrame: mapContainerView.bounds, camera: camera)
        mapView?.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        mapView?.delegate = self // Set the delegate after initializing the mapView
        
        mapContainerView.addSubview(mapView!)
        beginLocationUpdate()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        beginLocationUpdate()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first, currentLocation == nil {
            currentLocation = location.coordinate
            updateMapCamera(location.coordinate)
            mapView?.camera = GMSCameraPosition(target: location.coordinate, zoom: 15.0)
            mapView?.isMyLocationEnabled = true
            mapView?.settings.myLocationButton = true
            mapView?.settings.zoomGestures = true //allows for zoom
            locationManager.stopUpdatingLocation() //why is this here? stop updating location
        }
    }
    
    func beginLocationUpdate() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func updateMapCamera(_ coordinate: CLLocationCoordinate2D) {
        let cameraUpdate = GMSCameraUpdate.setTarget(coordinate, zoom: 20.0)
        mapView?.animate(with: cameraUpdate)
        mapView?.isMyLocationEnabled = true
        mapView?.settings.myLocationButton = true
    }
    
    func calculateWaypointAdjustment(for desiredTime: Int) -> Double {
        // Adjust this logic as needed for your app
        switch desiredTime {
        case 30:
            return 0.005 // Smaller range for shorter routes
        case 45:
            return 0.010 // Medium range
        case 60, 90:
            return 0.015 // Larger range for longer routes
        default:
            return 0.005 // Default range
        }
    }
    
    @IBAction func useRoute() {
        if storedRouteDetails != nil {
            performSegue(withIdentifier: "showRoute", sender: self)
        } else {
            
            errorLabel()
        }
    }
    
    
    
    
    @IBAction func searchRoute(_ sender: UIButton) {
        print("Search button pressed")
        removeErrorLabel()
        currentRoutePolyline?.map = nil
        currentRoutePolyline = nil
        mapView?.clear()
        if var currentLocation = self.currentLocation,
           let buttonText = sender.titleLabel?.text,
           let desiredTime = Int(buttonText.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()) {
            print("Current location is available: \(currentLocation)")
            print("Desired time: \(desiredTime)")
            findBestRoute(from: currentLocation, desiredTime: desiredTime)
        } else {
            print("Current location is not available or invalid route time.")
        }
    }
    
    func findBestRoute(from start: CLLocationCoordinate2D, desiredTime: Int) {
        passWaypoint.removeAll()

        var closestDuration = Int.max
        var bestRouteDetails: (polyString: String, durationText: String)?
        let group = DispatchGroup()
        //
        //        for _ in 1...2 {
        group.enter()
        randomwaypoint.findRoute(start, desiredTime: desiredTime, types: chosenType, mode: "Time") { placeInfos in
            for placeInfo in placeInfos {
                print("already go findroute")
                if let placeInfo = placeInfo{
                    DispatchQueue.main.async{
                        print("This will print on the main thread")
                        self.marker.addMarker(placeInfo, self.mapView, blue: true)

                    }
                    self.passWaypoint.append(placeInfo)
                }
            }
            self.requestRoute(from: start, waypoints: placeInfos.map(\.!.coordinate)) { polyString, duration in
                let durationInMinutes = duration / 60
                if abs(durationInMinutes - desiredTime) < abs(closestDuration - desiredTime) {
                    closestDuration = durationInMinutes
                    bestRouteDetails = (polyString, "\(durationInMinutes) 分")
                }
                
                group.leave()
            }
        }
        
        
        
        
        //        }
        
        group.notify(queue: .main) {
            if let routeDetails = bestRouteDetails {
                self.storedRouteDetails = RouteDetails(
                    polyString: routeDetails.polyString,
                    durationText: routeDetails.durationText,
                    startCoordinate: start
                )
                print("displaying route on map")
                // Update the map with the newly found route
                self.displayRouteOnMap(polyString: routeDetails.polyString, start: start, durationText: routeDetails.durationText)
            } else {
                print("No best route found, displaying the first route anyway.")
                
                // Generate random waypoints for the first route
                let firstWaypoints = self.generateRandomWaypoints(from: start, count: 2, adjustment: self.calculateWaypointAdjustment(for: desiredTime))
                
                // Check if firstWaypoints is not nil before using it
                if !firstWaypoints.isEmpty {
                    self.requestRoute(from: start, waypoints: firstWaypoints) { polyString, duration in
                        self.displayRouteOnMap(polyString: polyString, start: start, durationText: "\(duration / 60) min")
                    }
                } else {
                    print("Failed to generate random waypoints for the first route.")
                }
            }
        }
    }
    
    
    
    
    func generateRandomWaypoints(from start: CLLocationCoordinate2D, count: Int, adjustment: Double) -> [CLLocationCoordinate2D] {
        return (1...count).map { _ in
            CLLocationCoordinate2D(latitude: start.latitude + Double.random(in: -adjustment...adjustment),
                                   longitude: start.longitude + Double.random(in: -adjustment...adjustment))
        }
    }
    
    func requestRoute(from start: CLLocationCoordinate2D, waypoints: [CLLocationCoordinate2D], completion: @escaping (String, Int) -> Void) {
        let waypointsString = waypoints.map { "\($0.latitude),\($0.longitude)" }.joined(separator: "|")
        let origin = "\(start.latitude),\(start.longitude)"
        let encodedWaypoints = waypointsString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin)&destination=\(origin)&waypoints=\(encodedWaypoints)&mode=walking&key=\(APIKeys.shared.GMSServices)"
        
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion("", Int.max)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                completion("", Int.max)
                return
            }
            
            guard let data = data else {
                print("No data received")
                completion("", Int.max)
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String: AnyObject]
                
                guard let routes = json["routes"] as? [Any], !routes.isEmpty,
                      let route = routes[0] as? [String: Any],
                      let overviewPolyline = route["overview_polyline"] as? [String: Any],
                      let polyString = overviewPolyline["points"] as? String,
                      let legs = route["legs"] as? [[String: AnyObject]] else {
                    completion("", Int.max)
                    return
                }
                
                let totalDurationSeconds = legs.compactMap { $0["duration"] as? [String: AnyObject] }.compactMap { $0["value"] as? Int }.reduce(0, +)
                completion(polyString, totalDurationSeconds)
            } catch {
                print("JSON parsing error")
                completion("", Int.max)
            }
        }.resume()
    }
    
    func displayRouteOnMap(polyString: String, start: CLLocationCoordinate2D, durationText: String) {
        if let path = GMSPath(fromEncodedPath: polyString) {
            let polyline = GMSPolyline(path: path)
            polyline.strokeWidth = 5.0
            polyline.strokeColor = UIColor.systemBlue
            polyline.map = mapView
            
            self.currentRoutePolyline = polyline
            
            let bounds = GMSCoordinateBounds(path: path)
            let update = GMSCameraUpdate.fit(bounds, withPadding: 50)
            mapView?.animate(with: update)
            
            let durationMarker = GMSMarker(position: start)
            durationMarker.title = "開始地点"
            durationMarker.snippet = "予測時間: \(durationText)"
            durationMarker.map = mapView
            mapView?.selectedMarker = durationMarker
        } else {
            print("Failed to draw the route on the map.")
        }
    }
    
    func randomCoordinateOffset() -> Double {
        return Double.random(in: -0.005...0.005)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showRoute",
           let destinationVC = segue.destination as? RouteViewController,
           let _ = storedRouteDetails {
            destinationVC.routeDetails = storedRouteDetails
            // Assuming storedRouteDetails has the waypoints
            print("passed waypoint")
            destinationVC.waypoints = passWaypoint
            // Replace with actual way to access waypoints
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
        // Assuming you want the profile image URL
        if let imageUrl = user.profile?.imageURL(withDimension: 80) {
            downloadImage(from: imageUrl) { image in
                DispatchQueue.main.async {
                    self.profilePic.setImage(image, for: .normal)
                    self.profilePic.imageView?.contentMode = .scaleToFill
                    
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
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        if marker.title == "開始地点"{
            //print ("is start thing clicked")
            return nil
        } else if marker.icon == GMSMarker.markerImage(with: .red){
            print("marker probably destination")
            return nil
        }

        let infoWindow = CustomInfoWindow()
        infoWindow.frame = CGRect(x:0, y:0, width: 300, height: 200)
        infoWindow.titleLabel.text = marker.title
        print("marker snippet: ", marker.snippet)
        let snippetComponents = marker.snippet?.split(separator: ",")
        if let components = snippetComponents {
            if components.count >= 2 {
                // Extract rating
                
                let ratingString = components[0].replacingOccurrences(of: "評価：", with: "").trimmingCharacters(in: .whitespaces)
                print("rating is:", ratingString)

                if let ratingDouble = Double(ratingString) {
                    let rating = Int(round(ratingDouble))
                    infoWindow.updateStars(rating: rating)
                } else {
                    print("Invalid rating value")
                }

                // Extract type
                let typeString = components[1].replacingOccurrences(of: "ジャンル：", with: "").trimmingCharacters(in: .whitespaces)
                let typeAttributedString = NSMutableAttributedString(string: "ジャンル：", attributes: [.font: UIFont.boldSystemFont(ofSize: infoWindow.snippetLabel.font.pointSize)])
                typeAttributedString.append(NSAttributedString(string: typeString))
                infoWindow.snippetLabel.attributedText = typeAttributedString

                
                
                // Extract opening hours if available
                if components.count >= 3 {
                    let openingHoursString = components[2].replacingOccurrences(of: "営業時間：", with: "").trimmingCharacters(in: .whitespaces)
                    let hoursAttributedString = NSMutableAttributedString(string: "営業時間：", attributes: [.font: UIFont.boldSystemFont(ofSize: infoWindow.hoursLabel.font.pointSize)])
                    hoursAttributedString.append(NSAttributedString(string: openingHoursString))
                    infoWindow.hoursLabel.attributedText = hoursAttributedString
                } else {
                    infoWindow.hoursLabel.text = "営業時間情報なし" // Set a default value if opening hours are not available
                }
            }
        }
        
        
        if let photo = marker.userData as? UIImage {
            print("Userdata is valid")
            DispatchQueue.main.async {
                marker.tracksInfoWindowChanges = true
                infoWindow.pictureView.image = photo
                marker.tracksInfoWindowChanges = false
            }
        }
        return infoWindow // This ensures a UIView? is always returned
    }
    
    /* func setupStyle() {
     navigationView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.8272664657)
     setupBorder(button30)
     setupBorder(button45)
     setupBorder(button60)
     setupBorder(button90)
     setupBorder(startButton)
     }
     func setupBorder (_ a: UIButton){
     a.layer.borderWidth = 4
     a.layer.borderColor = #colorLiteral(red: 0.5058823529, green: 0.6274509804, blue: 0.9098039216, alpha: 1)
     a.layer.cornerRadius = a.frame.width / 2
     }*/
    func setupStyle() {
        navigationView.backgroundColor = #colorLiteral(red: 0.9279547334, green: 0.9279547334, blue: 0.9279547334, alpha: 1)
        
        // Update button styles
        setupButtonStyle(button30)
        setupButtonStyle(button45)
        setupButtonStyle(button60)
        setupButtonStyle(button90)
       // setupButtonStyle(startButton)
    }
    
    
    
    func setupButtonStyle(_ button: UIButton) {
        // Set button background color to #4F86FF
        button.backgroundColor = UIColor(red: 79/255, green: 134/255, blue: 255/255, alpha: 1.0) // #4F86FF
        
//        // Set button border
//        button.layer.borderWidth = 5
//        button.layer.borderColor = UIColor.white.cgColor
//        
        // Set button corner radius
        button.layer.cornerRadius = button.frame.width / 2
        
        // Apply drop shadow
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 4
        button.layer.shadowOpacity = 0.25
    
    }
    
    func setupChoiceButton(){
        let actionClosure = { (action: UIAction) in
            self.chosenType = action.title
        }
        var menuChildren: [UIMenuElement] = []
        
        for type in placeTypes {
            menuChildren.append(UIAction(title: type, handler: actionClosure))
        }
        
        typeChoiceButton.menu = UIMenu(options: .displayInline, children: menuChildren)
        typeChoiceButton.showsMenuAsPrimaryAction = true
        typeChoiceButton.changesSelectionAsPrimaryAction = true
    }
    
    //バーのコード
    
    
    func createLabel(_ text: String, fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor.black
        label.font = UIFont(name: "NotoSansJP-Regular", size: fontSize) // Fix: added fontSize parameter
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
    

    func createBarButton(title: String, imageName: String, fontSize: CGFloat) -> UIButton {
        let button = UIButton(type: .system)
        
        if let image = UIImage(named: imageName) {
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 30, right: 0) // Adjust as needed
        }
        
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: fontSize)
        button.titleLabel?.textAlignment = .center
        
        return button
    }
    
    
    @IBAction func likeLocation() {
        print("pressed heart")
        heart.setImage(UIImage(systemName: "heart.fill"), for: .normal)
    }
    
    // MARK: - eror label stuff
    func errorLabel(){
        if errorLabelReference != nil {
            removeErrorLabel()
        }

        let labelWidth: CGFloat = 250
        let labelHeight: CGFloat = 50
        
        // Assuming this code is inside a ViewController method
        let screenWidth = UIScreen.main.bounds.width
        let screenHeight = UIScreen.main.bounds.height
        
        let labelX = (screenWidth / 2) - (labelWidth / 2)
        //        let labelY = screenHeight * 0.5
        
        let myLabel = UILabel(frame: CGRect(x: labelX, y: 190, width: labelWidth, height: labelHeight))
        myLabel.text = "散歩時間を設定してください"
        myLabel.textAlignment = .center
        myLabel.backgroundColor = .red // For visibility
        myLabel.textColor = .white
        myLabel.layer.cornerRadius = 10
        myLabel.layer.masksToBounds = true
        myLabel.alpha = 0.95
        
        view.addSubview(myLabel)
        errorLabelReference = myLabel

    }
    
    func removeErrorLabel() {
        // Check if the label exists and remove it
        if let label = errorLabelReference {
            label.removeFromSuperview()
            errorLabelReference = nil // Clear the reference after removing
        }
    }
    
}

class HalfSizePresentationController: UIPresentationController {
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else { return .zero }
        return CGRect(x: 0, y: containerView.bounds.height / 2, width: containerView.bounds.width, height: containerView.bounds.height / 2)
    }
}

class CustomTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return HalfSizePresentationController(presentedViewController: presented, presenting: presenting)
    }
}
