import UIKit
import GoogleSignIn
import GoogleMaps
import GooglePlaces

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc")
        GMSPlacesClient.provideAPIKey("AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc")

//        window = UIWindow(frame: UIScreen.main.bounds)
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//
//        // Initially show a splash or loading screen
//        let waitViewController = storyboard.instantiateViewController(withIdentifier: "WaitViewController")
//        window?.rootViewController = waitViewController
//        window?.makeKeyAndVisible()
//
//        // Restore previous sign-in with a slight delay
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
//            GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
//                DispatchQueue.main.async {
//                    guard let self = self else { return }
//
//                    if user != nil {
//                        print("user is logged")
//                        let mainNavController = storyboard.instantiateViewController(withIdentifier: "MainNavigationController") as? UINavigationController
//                        self.window?.rootViewController = mainNavController
//                    } else {
//                        print("user isnot logged")
//                        let loginVC = storyboard.instantiateViewController(withIdentifier: "LoginViewController") as? LoginViewController
//                        self.window?.rootViewController = loginVC
//                    }
//                    self.window?.makeKeyAndVisible()
//                }
//            }

        return true
    }


    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      return GIDSignIn.sharedInstance.handle(url)
    }
}
