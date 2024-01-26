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
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                print("user not signed in with google")
            } else {
                print("user now signed in with google")
            }
        }
        
        // MARK: write realm config
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: 3,

            // Set the block which will be called automatically when opening a Realm
            // with a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 1) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
            }
        )

        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let handledByLoginManager = LoginManager.shared.application(app, open: url)
        let handledByGoogleSignIn = GIDSignIn.sharedInstance.handle(url)

        return handledByLoginManager || handledByGoogleSignIn
    }
}
