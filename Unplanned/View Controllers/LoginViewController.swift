//
//  LoginViewController.swift
//  Unplanned
//
//  Created by True Metal on 5/25/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import DigitsKit
import Parse

class LoginViewController: BaseViewController
{
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let authButton = DGTAuthenticateButton(authenticationCompletion: { (session: DGTSession?, error: NSError?) in
            if let session = session { self.createAccount(session) }
        })
        authButton.center = self.view.center
        authButton.setTitle("Get Started", forState: .Normal)
        self.view.addSubview(authButton)
    }
    
    func createAccount(session:DGTSession)
    {
        hudShow()
        if let userQuery = PFUser.query() {
            userQuery.whereKey("username", equalTo: session.phoneNumber)
            userQuery.getFirstObjectInBackgroundWithBlock({ (user, error) in
                self.hudHide()
                if user == nil { self.createUser(session) }
                else { self.loginUser(login:session.phoneNumber, password: session.userID) }
            })
        }
    }
    
    func loginUser(login login:String, password:String)
    {
        hudShow()
        PFUser.logInWithUsernameInBackground(login, password: password, block: { (user, error) in
            self.hudHide()
            
            guard user != nil else {
                UIMsg("Failed to log in")
                return
            }

            if (PFUser.currentUser() != nil) {
                registerPFUserForPushNotifications(PFUser.currentUser()!)

                FriendsFinderHelper.startMatchingParseFriendsWithDigits(sendNotificationsToMatchedUsers: false, completionBlock: {
                })
            }
            AppDelegate.delegate.setLoggedInVC(true)
        })
    }
    
    func createUser(session:DGTSession)
    {
        let user = UserModel()
        user.username = session.phoneNumber
        user.password = session.userID
        user.digitsUserId = session.userID
        
        hudShow()
        user.signUpInBackgroundWithBlock { (success, error) in
            self.hudHide()
            
            guard success else {
                UIMsg("Failed to sign up \(error?.localizedDescription ?? "")")
                return
            }
            
            AppDelegate.delegate.setLoggedInVC(true)
        }
    }
    
    // ---
    
    override func hasDevFacilities() -> Bool {
        return true
    }
    
    override func setupDevFacilityActionSheet(sheet: UIAlertController) {
        sheet.addAction(UIAlertAction(title: "login with testuser1", style: .Default, handler: { (action) in
            self.loginUser(login: "testuser1", password: "testuser1")
        }))
    }
}
