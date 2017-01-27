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

    class var delegate:AppDelegate { get { return UIApplication.sharedApplication().delegate! as! AppDelegate } }
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool
    {
        let configuration = ParseClientConfiguration {
            $0.applicationId = "O2EoKviDXMzRp4FKVtAQZpWXxG3ghSAjLJlWUcKq"
            $0.clientKey = "JreyDvMTYQlMfA9UcpxZcyLfzUUKLpW3rsoEU4wg"
        }
        Parse.initializeWithConfiguration(configuration)
        PFUser.enableRevocableSessionInBackground()
        
        Fabric.with([Digits.self(), Crashlytics.self(), Answers.self()])
        
        if PFUser.currentUser() != nil {
            setLoggedInVC(false)
            
            let firstLaunch = NSUserDefaults.standardUserDefaults().boolForKey("FirstLaunch")
            
            if (!firstLaunch){
                registerPFUserForPushNotifications(PFUser.currentUser()!)
                
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: "FirstLaunch")
            }

            FriendsFinderHelper.startMatchingParseFriendsWithDigits(sendNotificationsToMatchedUsers: false, completionBlock: {

            })
        }

        FriendsFinderHelper.startObservingAddressBookChanges()

        if application.applicationState != UIApplicationState.Background {
            // Track an app open here if we launch with a push, unless
            // "content_available" was used to trigger a background push (introduced in iOS 7).
            // In that case, we skip tracking here to avoid double counting the app-open.
            
            let preBackgroundPush = !application.respondsToSelector(Selector("backgroundRefreshStatus"))
            let oldPushHandlerOnly = !self.respondsToSelector(#selector(UIApplicationDelegate.application(_:didReceiveRemoteNotification:fetchCompletionHandler:)))
            var noPushPayload = false;
            if let options = launchOptions {
                noPushPayload = options[UIApplicationLaunchOptionsRemoteNotificationKey] != nil;
            }
            if (preBackgroundPush || oldPushHandlerOnly || noPushPayload) {
                PFAnalytics.trackAppOpenedWithLaunchOptions(launchOptions)
            }
        }
        
        
        self.pushNotificationController = PushNotificationController()
        
        // Register for Push Notitications, if running iOS 8
        if application.respondsToSelector(#selector(UIApplication.registerUserNotificationSettings(_:))) {
            let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
            
            application.registerUserNotificationSettings(settings)
            application.registerForRemoteNotifications()
            
        } else {
            // Register for Push Notifications before iOS 8
            application.registerForRemoteNotificationTypes([.Alert, .Badge, .Sound])
        }
        
        
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let installation = PFInstallation.currentInstallation()
        installation.setDeviceTokenFromData(deviceToken)
        installation.saveInBackground()
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        if error.code == 3010 {
            print("Push notifications are not supported in the iOS Simulator.")
        } else {
            print("application:didFailToRegisterForRemoteNotificationsWithError: %@", error)
        }
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("didReceiveRemoteNotification")
        
        if application.applicationState == .Inactive {
            // The application was just brought from the background to the foreground, so we consider the app as having been "opened by a push notification."
            PFAnalytics.trackAppOpenedWithRemoteNotificationPayload(userInfo)
        }
        
        
        PFPush.handlePush(userInfo)

        NotificationsHelper.badgeNotification.post(nil)
    }
    
    func applicationDidBecomeActive(application: UIApplication) {

    }
    
    
    func storyboard() -> UIStoryboard
    {
        return UIStoryboard(name: "Main", bundle: nil) ?? UIStoryboard()
    }

    func setAuthVC()
    {
        guard let newVc = storyboard().instantiateInitialViewController(), currentVc = window?.rootViewController else { return }
        
        UIView.transitionFromView(currentVc.view, toView: newVc.view, duration: 0.4, options: .TransitionFlipFromLeft) { (finished) in
            if finished { self.window?.rootViewController = newVc }
        }
    }
    
    func setLoggedInVC(animated:Bool)
    {
        guard let currentVc = window?.rootViewController else { return }
        
        let newVc = UserModel.currentUser()!.isProfileCreated ? mainMenuVc() : storyboard().instantiateViewControllerWithIdentifier("CreateProfileViewController") as! CreateProfileViewController
        self.window?.rootViewController = UINavigationController(rootViewController: newVc)
        UIView.transitionFromView(currentVc.view, toView: newVc.view, duration: animated ? 0.4 : 0, options: .TransitionFlipFromRight) { (finished) in
            if finished {
                //self.window?.rootViewController = UINavigationController(rootViewController: newVc)
            }
        }
    }
    
    func mainMenuVc() -> UIViewController{
        
        
        let feedVC = storyboard().instantiateViewControllerWithIdentifier("FeedViewController") as! FeedViewController
        self.window?.rootViewController = UINavigationController(rootViewController: feedVC)
        
        return feedVC
    }
}

