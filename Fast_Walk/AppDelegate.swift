import UIKit
import GoogleSignIn
import GoogleMaps
import GooglePlaces



@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize the window
        window = UIWindow(frame: UIScreen.main.bounds)
        
        GMSServices.provideAPIKey("AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc")
        GMSPlacesClient.provideAPIKey("AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc")

        
        window = UIWindow(frame: UIScreen.main.bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyboard.instantiateViewController(withIdentifier: "DeciderViewController")
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        return true
    }

    
    
    func application(
      _ app: UIApplication,
      open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]
    ) -> Bool {
      var handled: Bool

      handled = GIDSignIn.sharedInstance.handle(url)
      if handled {
        return true
      }

      // Handle other custom URL types.

      // If not handled by this app, return false.
      return false
    }
}
