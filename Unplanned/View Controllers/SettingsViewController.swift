//
//  ShareViewController.swift
//  Unplanned
//
//  Created by matata on 31.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import DigitsKit
import Parse
import MessageUI

class SettingsViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate, MFMessageComposeViewControllerDelegate {

    @IBOutlet weak var tableView: UITableView!
    var isSettings = true
     var listItemsOfSettings = []
    var countOfSections = 1
    
    @IBOutlet weak var heightOfTable: NSLayoutConstraint!
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        
        self.createNavigationBarButtons()
        if (isSettings) {
            listItemsOfSettings = ["Change phone".localized(), "Invite friends".localized(), "Legal".localized(), "Log out".localized()]
            self.countOfSections = 2
            self.setupGradienNavigationBar("Settings".localized())
            self.heightOfTable.constant = tableView.rowHeight * 5 + tableView.sectionHeaderHeight * 2 + 13
            
        } else {
            listItemsOfSettings = ["Facebook", "SMS"]
            self.countOfSections = 1
            self.setupGradienNavigationBar("Share".localized())
            self.heightOfTable.constant = tableView.rowHeight * 3 + tableView.sectionHeaderHeight * 1 + 13
        }
        self.view.layoutIfNeeded()
    }
    
    
    func createNavigationBarButtons(){
        var menuImage:UIImage = UIImage(named: "icon_back_button")!
        
        menuImage = menuImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let menuButton: UIButton = UIButton(frame: CGRectMake(5, 5, 20, 20))
        menuButton.setImage(menuImage, forState: .Normal)
        menuButton.setImage(menuImage, forState: .Highlighted)
        menuButton.addTarget(self, action: #selector(CreateEventViewController.close(_:)), forControlEvents:.TouchUpInside)
        let menuButtonBar = UIBarButtonItem.init(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuButtonBar
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hecho", style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventViewController.submit(_:)))
        
    }
    
    func close(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    func submit(sender : UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return " "
        } else {
            return "Acerca de"
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if !isSettings {
            
            switch indexPath.row {
            case 0:
                self.shareFacebook()
                break
            default:
                self.shareSms()
                break
                
            }
        }
        
        if isSettings {
            
            switch indexPath.row {
            case 0:
                
                if indexPath.section == 0 {
                    logOut()
                } else {
                    openLegalUrl()
                }
                
                break
            case 1:
                if indexPath.section == 0 {
                    self.shareToAll()
                } else {
                   logOut()
                }
                
                break
            default:
                break
                
            }
            
            
        
        }
    }
    
    func logOut() {
        Digits.sharedInstance().logOut()
        PFUser.logOut()
        AppDelegate.delegate.setAuthVC()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.countOfSections
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SettingsTableViewCell") as! SettingsTableViewCell
        
        print(indexPath.section)
        
        switch indexPath.section {
        case 0:
            cell.labelTitle.text = self.listItemsOfSettings[indexPath.row] as? String
            break
        case 1:
            cell.labelTitle.text = self.listItemsOfSettings[indexPath.row + 2] as? String
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFontOfSize(14.0)
        header.textLabel?.textColor = UIColor.grayColor()
         header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
    }
    
    
    func shareFacebook() {
        let screen = UIScreen.mainScreen()
        
        if let window = UIApplication.sharedApplication().keyWindow {
            UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0);
            window.drawViewHierarchyInRect(window.bounds, afterScreenUpdates: false)
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            let composeSheet = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
            composeSheet.setInitialText("Hi, pls download app UnPlanned!")
            composeSheet.addImage(image)
            
            presentViewController(composeSheet, animated: true, completion: nil)
        }    }
    
    func shareSms() {
        if (MFMessageComposeViewController.canSendText()) {
            let controller = MFMessageComposeViewController();
            controller.body = "Hi, pls download app UnPlanned";
            //controller.recipients = ["(415) 555-4387"]
            controller.messageComposeDelegate = self;
            self.presentViewController(controller, animated: true, completion: nil);
        }
    }
    
    func messageComposeViewController(controller: MFMessageComposeViewController, didFinishWithResult result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResultCancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResultFailed.rawValue :
            print("message failed")
            
        case MessageComposeResultSent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func shareToAll() {
        let textToShare = "Try download app UnPlanned! "
        
        if let myWebsite = NSURL(string: "http://www.codingexplorer.com/") {
            let objectsToShare = [textToShare, myWebsite]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.presentViewController(activityVC, animated: true, completion: nil)
        }
    }
    
    func openLegalUrl() {
        let url = NSURL(string: "https://google.com")!
        UIApplication.sharedApplication().openURL(url)
    }
}
    

