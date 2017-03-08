//
//  AppDelegate.swift
//  Unplanned
//
//  Created by True Metal on 5/25/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import Fabric
import DigitsKit
import Crashlytics
import QuadratTouch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    var pushNotificationController:PushNotificationController?

    class var delegate:AppDelegate { get { return UIApplication.shared.delegate! as! AppDelegate } }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool
    {
        let configuration = ParseClientConfiguration {
            $0.applicationId = "O2EoKviDXMzRp4FKVtAQZpWXxG3ghSAjLJlWUcKq"
            $0.clientKey = "JreyDvMTYQlMfA9UcpxZcyLfzUUKLpW3rsoEU4wg"
        }
        Parse.initialize(with: configuration)
        PFUser.enableRevocableSessionInBackground()
        
        Fabric.with([Digits.self(), Crashlytics.self(), Answers.self()])
        
        if PFUser.current() != nil {
            setLoggedInVC(false)
            
            let firstLaunch = UserDefaults.standard.bool(forKey: "FirstLaunch")
            
            if (!firstLaunch){
                registerPFUserForPushNotifications(PFUser.current()!)
                
                UserDefaults.standard.set(true, forKey: "FirstLaunch")
            }

            FriendsFinderHelper.startMatchingParseFriendsWithDigits(sendNotificationsToMatchedUsers: false, completionBlock: {

            })
        }

        FriendsFinderHelper.startObservingAddressBookChanges()

        if application.applicationState != UIApplicationState.background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.responds(to: #selector(getter: UIApplication.backgroundRefreshStatus))
            let oldPushHandlerOnly = !self.responds(to: #selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsKey.remoteNotification] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpened(launchOptions: launchOptions)
            }
        }
        
        
        self.pushNotificationController = PushNotificationController()
        
        // Register for Push Notitications, if running iOS 8
        if application.responds(to: #selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotifications(matching: [.alert, .badge, .sound])
        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let installation = PFInstallation.current()
        installation.setDeviceTokenFrom(deviceToken)
        installation.saveInBackground()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print("didReceiveRemoteNotification")
        
        if application.applicationState == .inactive {
            // The application was just brought from the background to the foreground, so we consider the app as having been "opened by a push notification."
            PFAnalytics.trackAppOpened(withRemoteNotificationPayload: userInfo)
        }
        
        
        PFPush.handle(userInfo)

        NotificationsHelper.badgeNotification.post(nil)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {

    }
    
    
    func storyboard() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: nil) ?? UIStoryboard()
    }

    func setAuthVC()
    {
        guard let newVc = storyboard().instantiateInitialViewController(), let currentVc = window?.rootViewController else { return }
        
        UIView.transition(from: currentVc.view, to: newVc.view, duration: 0.4, options: .transitionFlipFromLeft) { (finished) in
            if finished { self.window?.rootViewController = newVc }
        }
    }
    
    func setLoggedInVC(_ animated:Bool)
    {
        guard let currentVc = window?.rootViewController else { return }
        
        let newVc = UserModel.current()!.isProfileCreated ? mainMenuVc() : storyboard().instantiateViewController(withIdentifier: "CreateProfileViewController") as! CreateProfileViewController
        self.window?.rootViewController = UINavigationController(rootViewController: newVc)
        UIView.transition(from: currentVc.view, to: newVc.view, duration: animated ? 0.4 : 0, options: .transitionFlipFromRight) { (finished) in
            if finished {
                //self.window?.rootViewController = UINavigationController(rootViewController: newVc)
            }
        }
    }
    
    func mainMenuVc() -> UIViewController{
        
        
        let feedVC = storyboard().instantiateViewController(withIdentifier: "FeedViewController") as! FeedViewController
        self.window?.rootViewController = UINavigationController(rootViewController: feedVC)
        
        return feedVC
    }
}

