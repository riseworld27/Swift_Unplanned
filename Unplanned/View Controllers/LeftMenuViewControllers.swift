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
        
        if let fName = PFUser.current()!.value(forKey: "firstName") as? String {
                if let lName = PFUser.current()!.value(forKey: "lastName") as? String {
                    self.labelUserName.text = "\(fName) \(lName)"
            }
        }
        
        if let imageUrl = PFUser.current()?.value(forKey: "photo") as? PFFile {
            self.ivProfilePhoto.kf_setImageWithURL(URL(string: imageUrl.url!)!)
        }

        badgeObserver = NotificationObserver(NotificationsHelper.badgeNotification) {
            [unowned self] (value, sender) in

            self.countNotifications = UIApplication.shared.applicationIconBadgeNumber
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
                self.countNotifications = UIApplication.shared.applicationIconBadgeNumber
                self.tableView.reloadData()
        
        if PFUser.current() != nil  {
            PFUser.current()?.fetchInBackground()
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "menuTableViewCell", for: indexPath) as! MenuTableViewCell
        
        let row = indexPath.row

        switch row {
        case 0:
            cell.labelTitleMenu.text = "Feed".localized()
            cell.labelCountNotifications.isHidden = self.countNotifications != 0 ? false : true
            cell.labelCountNotifications.text = self.countNotifications != 0 ? "\(self.countNotifications)" : ""
            cell.ivIconMenu.image = UIImage(named: "icon_menu_feed")
            break
        case 1:
            cell.labelTitleMenu.text = "My Groups".localized()
            cell.labelCountNotifications.isHidden = true
            cell.ivIconMenu.image = UIImage(named: "icon_menu_groups")
            break
        case 2:
            cell.labelCountNotifications.isHidden = true
            cell.labelTitleMenu.text = "Settings".localized()
            cell.ivIconMenu.image = UIImage(named: "icon_menu_settings")
            break
        case 3:
            cell.labelCountNotifications.isHidden = true
            cell.labelTitleMenu.text = "Share".localized()
            cell.ivIconMenu.image = UIImage(named: "icon_menu_share")
            break
        default:
            cell.labelCountNotifications.isHidden = true
            break
        }

        cell.labelCountNotifications.backgroundColor = UIColor(hex6: 0x672890)
        cell.labelCountNotifications.layer.cornerRadius = 9
        cell.labelCountNotifications.layer.masksToBounds = true;
        return cell

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        
        switch row {
        case 0:
            self.performSegue(withIdentifier: "segueOpenListFeed", sender: nil)
            break
        case 1:
            self.performSegue(withIdentifier: "segueOpenListGroups", sender: nil)
            break
        case 2:
            self.performSegue(withIdentifier: "segueOpenSettings", sender: true)
            break
        case 3:
            self.performSegue(withIdentifier: "segueOpenSettings", sender: false)
            break
        default:
            return
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueOpenSettings" {
            if let viewController: SettingsViewController = segue.destination as? SettingsViewController {
                viewController.isSettings = sender as! Bool
            }
        }
    }
    
    @IBAction func openEditProfile(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueOpenProfileEdit", sender: nil)
    }
    
}
