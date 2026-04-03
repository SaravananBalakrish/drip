import UIKit
import Flutter
import flutter_local_notifications
import GoogleMaps
import Firebase
import FirebaseAuth
import FirebaseMessaging
//
//@main
//@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate{
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    if FirebaseApp.app() == nil {
//      print("Configuring Firebase")
//      FirebaseApp.configure()
//    } else {
//      print("Firebase already configured")
//    }
//
//    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
//      GeneratedPluginRegistrant.register(with: registry)
//    }
//
//    GeneratedPluginRegistrant.register(with: self)
//    GMSServices.provideAPIKey("AIzaSyBMJi4_w-shxRfKJcqiDAd61g5w1CmxS48")
//
//    if #available(iOS 10.0, *) {
//      UNUserNotificationCenter.current().delegate = self
//    }
//    application.registerForRemoteNotifications()
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//
//    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
//        print("🔥 FCM Token: \(fcmToken ?? "")")
//        // Sync this token to your backend here
//      }
//  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//     Messaging.messaging().apnsToken = deviceToken // Set APNs token for FCM
//      print("apnsToken device token is \(deviceToken)")
////    let firebaseAuth = Auth.auth()
////    firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
//  }
//  
//  override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//    Messaging.messaging().appDidReceiveMessage(userInfo) // Handle FCM notifications
//    completionHandler(.newData)
//  }
//}
@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate { // <--- 1. Idha add pannunga
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    if FirebaseApp.app() == nil {
      FirebaseApp.configure()
    }

    // <--- 2. Idhu dhaan mukkiyam! Firebase kitta 'delegate' set panrom
    Messaging.messaging().delegate = self

    FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
      GeneratedPluginRegistrant.register(with: registry)
    }

    GeneratedPluginRegistrant.register(with: self)
    GMSServices.provideAPIKey("AIzaSyBMJi4_w-shxRfKJcqiDAd61g5w1CmxS48")

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    application.registerForRemoteNotifications()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // <--- 3. Indha function-ah AppDelegate kulla kalla add pannunga
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
    print(" FCM Token: \(fcmToken ?? "")")
  }

  override func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
