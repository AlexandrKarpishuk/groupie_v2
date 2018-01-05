//
//  AppDelegate.swift
//  groupie
//
//  Created by Xinran on 3/26/16.
//  Copyright © 2016 DaisyDaisy. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

import FBSDKCoreKit
import GoogleMaps
import GooglePlaces
//import SlideMenuControllerSwift


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        ValueTransformer.setValueTransformer(TransformableSet(), forName: .classNameTransformerName)
        
        
        GMSPlacesClient.provideAPIKey("AIzaSyCreyr14s1dbVDxqsGYKFoxUHATP_0hA7I")
        
  /*      let log = XCGLogger.default
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .debug)*/
        
        GMSServices.provideAPIKey(Keys.Google.APIKey)
        
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        let homeViewController = Constants.Storyboards.Main.instantiateViewController(withIdentifier: "homeVC") as! HomeViewController
        
        let sidebarViewController = Constants.Storyboards.Main.instantiateViewController(withIdentifier: "sideVC") as! SidebarViewController
        
        let navigationViewController: UINavigationController = UINavigationController(rootViewController: homeViewController)
        
        //let slideMenuController = SlideMenuController(mainViewController: navigationViewController, leftMenuViewController: sidebarViewController)
        
        let slideMenuController = CustomSlideMenuController(mainViewController: navigationViewController, leftMenuViewController: sidebarViewController)
        
        slideMenuController.automaticallyAdjustsScrollViewInsets = true
        
        UINavigationBar.appearance().shadowImage = UIImage ()
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().isTranslucent = true
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
              NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName:UIColor.clear,
              NSFontAttributeName:UIFont.systemFont(ofSize: 0.1)], for: .highlighted)


        self.window?.rootViewController = slideMenuController
        self.window?.makeKeyAndVisible()
        
        NotificationCenter.default.addObserver(self, selector: #selector(onLoggedIN), name: ServerManager.LOGGED_IN_NOTIFICATION, object: nil)
        
        let _ = LikesManager.shared // instantinate Likes manager
        let _ = FriendsManager.shared // instantinate Friends manager
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
 //       self.saveContext()
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let isHandled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return isHandled
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "daisydaisy.groupie" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "groupie", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info === \(notification.request.content.userInfo)")
        // Handle code here.
        self.didRecievedNotify(userInfo: notification.request.content.userInfo)
        
        completionHandler([UNNotificationPresentationOptions.sound , UNNotificationPresentationOptions.alert , UNNotificationPresentationOptions.badge])
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info === \(response.notification.request.content.userInfo)")
        completionHandler()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var deviceTokenString = ""
        for byte in deviceToken {
            deviceTokenString += String(format: "%02X", byte)
        }
        NSLog("APNS: \(deviceToken.description)\n\(deviceTokenString)")
        
        ServerManager.shared.UnRegisterForNotifications(apnsToken: deviceTokenString) {
            ServerManager.shared.RegisterForNotifications(apnsToken: deviceTokenString)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        print(userInfo)
        self.didRecievedNotify(userInfo: userInfo)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    fileprivate func didRecievedNotify(userInfo:[AnyHashable: Any]) {
        if let aps = userInfo[AnyHashable("aps")] as? [String: Any] {
            if let message = aps["alert"] as? String {
                AGPushNoteView.showWithNotificationMessage(message: message)
            }
        }
    }
    
    func requestForNotifications() {
        if (Thread.isMainThread) {
            if #available(iOS 10.0, *) {
                let center = UNUserNotificationCenter.current()
                center.delegate = self
                center.requestAuthorization(options: [.sound, .badge, .alert ], completionHandler: { (granted, error) in
                    if error == nil{
                        if (Thread.isMainThread) { UIApplication.shared.registerForRemoteNotifications()
                        } else {
                            DispatchQueue.main.async {
                                UIApplication.shared.registerForRemoteNotifications()
                            }
                        }
                    }
                })
            } else {
                let settings  = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
                UIApplication.shared.registerUserNotificationSettings(settings)
                UIApplication.shared.registerForRemoteNotifications()
            }
        } else {
            DispatchQueue.main.async {
                self.requestForNotifications()
            }
        }
    }
    
    func onLoggedIN() {
        self.requestForNotifications()
    }
}
