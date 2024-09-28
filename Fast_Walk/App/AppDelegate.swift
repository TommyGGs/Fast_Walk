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
        // Setup Google Maps and Places API keys
        GMSServices.provideAPIKey(APIKeys.shared.GMSServices)
        GMSPlacesClient.provideAPIKey(APIKeys.shared.GMSServices)

        // Setup LINE SDK
        LoginManager.shared.setup(channelID: "2002641031", universalLinkURL: nil)

        // Restore previous Google Sign-In session if it exists
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                print("Google Sign-In error: \(error.localizedDescription)")
            } else if let user = user {
                print("Google user is signed in: \(user.profile?.name ?? "Unknown")")
            } else {
                print("User not signed in with Google")
            }
        }

        // Realm configuration
        let config = Realm.Configuration(
            schemaVersion: 3,  // Increment this when the schema changes
            migrationBlock: { migration, oldSchemaVersion in
                // Perform any migration logic here if needed
                if oldSchemaVersion < 1 {
                    // Migration logic if needed
                }
            }
        )
        Realm.Configuration.defaultConfiguration = config

        // Initialize Realm to test the configuration
        do {
            _ = try Realm()
            print("Realm initialized successfully")
        } catch let error {
            print("Error initializing Realm: \(error.localizedDescription)")
        }

        return true
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        // Handle LINE login and Google Sign-In URLs
        let handledByLoginManager = LoginManager.shared.application(app, open: url)
        let handledByGoogleSignIn = GIDSignIn.sharedInstance.handle(url)

        return handledByLoginManager || handledByGoogleSignIn
    }
}
