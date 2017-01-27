//
//  SideMenuViewController.swift
//  Unplanned
//
//  Created by True Metal on 5/27/16.
//  Copyright © 2016 matata. All rights reserved.
//

import Foundation
import DigitsKit
import Parse

let friednsListNavStoryboardId = "friendsListNav"

class SideMenuViewController:BaseViewController
{
    @IBAction func btnFriendsListTap(sender: AnyObject) {
        setContentVC(friednsListNavStoryboardId)
    }
    
    func setContentVC(identifier:String)
    {
        
    }

    @IBAction func btnLogoutTap(sender: AnyObject) {
        Digits.sharedInstance().logOut()
        PFUser.logOut()
        AppDelegate.delegate.setAuthVC()
    }
}
