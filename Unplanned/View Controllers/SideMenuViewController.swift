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
    @IBAction func btnFriendsListTap(_ sender: AnyObject) {
        setContentVC(friednsListNavStoryboardId)
    }
    
    func setContentVC(_ identifier:String)
    {
        
    }

    @IBAction func btnLogoutTap(_ sender: AnyObject) {
        Digits.sharedInstance().logOut()
        PFUser.logOut()
        AppDelegate.delegate.setAuthVC()
    }
}
