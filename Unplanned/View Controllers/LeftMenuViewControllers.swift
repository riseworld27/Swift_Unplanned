//
//  LeftMenuViewControllers.swift
//  Unplanned
//
//  Created by matata on 28.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import Kingfisher
import JSQNotificationObserverKit

class LeftMenuViewControllers: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var ivProfilePhoto: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelUserName: UILabel!
    
    var countNotifications = 0

    var badgeObserver: NotificationObserver<Any?, AnyObject>?

    override func viewDidLoad() {
        ivProfilePhoto.layer.cornerRadius = ivProfilePhoto.frame.size.height/2
        ivProfilePhoto.clipsToBounds = true
        
        if let fName = PFUser.currentUser()!.valueForKey("firstName") as? String {
                if let lName = PFUser.currentUser()!.valueForKey("lastName") as? String {
                    self.labelUserName.text = "\(fName) \(lName)"
            }
        }
        
        if let imageUrl = PFUser.currentUser()?.valueForKey("photo") as? PFFile {
            self.ivProfilePhoto.kf_setImageWithURL(NSURL(string: imageUrl.url!)!)
        }

        badgeObserver = NotificationObserver(NotificationsHelper.badgeNotification) {
            [unowned self] (value, sender) in

            self.countNotifications = UIApplication.sharedApplication().applicationIconBadgeNumber
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        
                self.countNotifications = UIApplication.sharedApplication().applicationIconBadgeNumber
                self.tableView.reloadData()
        
        if PFUser.currentUser() != nil  {
            PFUser.currentUser()?.fetchInBackground()
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("menuTableViewCell", forIndexPath: indexPath) as! MenuTableViewCell
        
        let row = indexPath.row

        switch row {
        case 0:
            cell.labelTitleMenu.text = "Feed".localized()
            cell.labelCountNotifications.hidden = self.countNotifications != 0 ? false : true
            cell.labelCountNotifications.text = self.countNotifications != 0 ? "\(self.countNotifications)" : ""
            cell.ivIconMenu.image = UIImage(named: "icon_menu_feed")
            break
        case 1:
            cell.labelTitleMenu.text = "My Groups".localized()
            cell.labelCountNotifications.hidden = true
            cell.ivIconMenu.image = UIImage(named: "icon_menu_groups")
            break
        case 2:
            cell.labelCountNotifications.hidden = true
            cell.labelTitleMenu.text = "Settings".localized()
            cell.ivIconMenu.image = UIImage(named: "icon_menu_settings")
            break
        case 3:
            cell.labelCountNotifications.hidden = true
            cell.labelTitleMenu.text = "Share".localized()
            cell.ivIconMenu.image = UIImage(named: "icon_menu_share")
            break
        default:
            cell.labelCountNotifications.hidden = true
            break
        }

        cell.labelCountNotifications.backgroundColor = UIColor(hex6: 0x672890)
        cell.labelCountNotifications.layer.cornerRadius = 9
        cell.labelCountNotifications.layer.masksToBounds = true;
        return cell

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let row = indexPath.row
        
        switch row {
        case 0:
            self.performSegueWithIdentifier("segueOpenListFeed", sender: nil)
            break
        case 1:
            self.performSegueWithIdentifier("segueOpenListGroups", sender: nil)
            break
        case 2:
            self.performSegueWithIdentifier("segueOpenSettings", sender: true)
            break
        case 3:
            self.performSegueWithIdentifier("segueOpenSettings", sender: false)
            break
        default:
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueOpenSettings" {
            if let viewController: SettingsViewController = segue.destinationViewController as? SettingsViewController {
                viewController.isSettings = sender as! Bool
            }
        }
    }
    
    @IBAction func openEditProfile(sender: AnyObject) {
        self.performSegueWithIdentifier("segueOpenProfileEdit", sender: nil)
    }
    
}
