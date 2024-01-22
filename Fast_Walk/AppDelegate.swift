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
        
        
        Realm.Configuration.defaultConfiguration = Realm.Configuration(
            schemaVersion: 2, // Increment whenever schema changes
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    // Migrate from 'xCoordinate' and 'yCoordinate' to 'latitude' and 'longitude'
                    migration.enumerateObjects(ofType: FavoriteSpot.className()) { oldObject, newObject in
                        let xCoordinate = oldObject!["xCoordinate"] as! Double
                        let yCoordinate = oldObject!["yCoordinate"] as! Double
                        newObject!["latitude"] = xCoordinate
                        newObject!["longitude"] = yCoordinate
                    }
                }
            },
            deleteRealmIfMigrationNeeded: false // Set to true to delete the realm if migration is not possible
        )

        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        let handledByLoginManager = LoginManager.shared.application(app, open: url)
        let handledByGoogleSignIn = GIDSignIn.sharedInstance.handle(url)

        return handledByLoginManager || handledByGoogleSignIn
    }
}
