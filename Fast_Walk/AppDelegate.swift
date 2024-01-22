import UIKit
import GoogleSignIn
import GoogleMaps
import GooglePlaces
import LineSDK
import RealmSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey("AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc")
        GMSPlacesClient.provideAPIKey("AIzaSyAZae3XCwTFoxI2TopAfiSlzJsdFZ9IrIc")
        LoginManager.shared.setup(channelID: "2002641031", universalLinkURL: nil)
        
        let config = Realm.Configuration(schemaVersion: 1)
        Realm.Configuration.defaultConfiguration = config

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let handledByLoginManager = LoginManager.shared.application(app, open: url)
        let handledByGoogleSignIn = GIDSignIn.sharedInstance.handle(url)

        return handledByLoginManager || handledByGoogleSignIn
    }
}
