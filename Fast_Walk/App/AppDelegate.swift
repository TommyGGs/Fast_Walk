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
        GMSServices.provideAPIKey("\(APIKeys.shared.GMSServices)")
        GMSPlacesClient.provideAPIKey("\(APIKeys.shared.GMSServices)")

        LoginManager.shared.setup(channelID: "2002641031", universalLinkURL: nil)
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                print("user not signed in with google")
            } else {
                print("user now signed in with google")
            }
        }
        
        let config = Realm.Configuration(
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                if (oldSchemaVersion < 1) {
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let handledByLoginManager = LoginManager.shared.application(app, open: url)
        let handledByGoogleSignIn = GIDSignIn.sharedInstance.handle(url)

        return handledByLoginManager || handledByGoogleSignIn
    }
}
