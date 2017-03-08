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
    
    func createAccount(_ session:DGTSession)
    {
        hudShow()
        if let userQuery = PFUser.query() {
            userQuery.whereKey("username", equalTo: session.phoneNumber)
            userQuery.getFirstObjectInBackground(block: { (user, error) in
                self.hudHide()
                if user == nil { self.createUser(session) }
                else { self.loginUser(login:session.phoneNumber, password: session.userID) }
            })
        }
    }
    
    func loginUser(login:String, password:String)
    {
        hudShow()
        PFUser.logInWithUsername(inBackground: login, password: password, block: { (user, error) in
            self.hudHide()
            
            guard user != nil else {
                UIMsg("Failed to log in")
                return
            }

            if (PFUser.current() != nil) {
                registerPFUserForPushNotifications(PFUser.current()!)

                FriendsFinderHelper.startMatchingParseFriendsWithDigits(sendNotificationsToMatchedUsers: false, completionBlock: {
                })
            }
            AppDelegate.delegate.setLoggedInVC(true)
        })
    }
    
    func createUser(_ session:DGTSession)
    {
        let user = UserModel()
        user.username = session.phoneNumber
        user.password = session.userID
        user.digitsUserId = session.userID
        
        hudShow()
        user.signUpInBackground { (success, error) in
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
    
    override func setupDevFacilityActionSheet(_ sheet: UIAlertController) {
        sheet.addAction(UIAlertAction(title: "login with testuser1", style: .default, handler: { (action) in
            self.loginUser(login: "testuser1", password: "testuser1")
        }))
    }
}
