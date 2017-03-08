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
    
    override func viewWillAppear(_ animated: Bool) {
        
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
        
        menuImage = menuImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let menuButton: UIButton = UIButton(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        menuButton.setImage(menuImage, for: UIControlState())
        menuButton.setImage(menuImage, for: .highlighted)
        menuButton.addTarget(self, action: #selector(CreateEventViewController.close(_:)), for:.touchUpInside)
        let menuButtonBar = UIBarButtonItem.init(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuButtonBar
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Hecho", style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateEventViewController.submit(_:)))
        
    }
    
    func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func submit(_ sender : UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return " "
        } else {
            return "Acerca de"
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.countOfSections
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsTableViewCell") as! SettingsTableViewCell
        
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
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        header.textLabel?.textColor = UIColor.gray
         header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
    }
    
    
    func shareFacebook() {
        let screen = UIScreen.main
        
        if let window = UIApplication.shared.keyWindow {
            UIGraphicsBeginImageContextWithOptions(screen.bounds.size, false, 0);
            window.drawHierarchy(in: window.bounds, afterScreenUpdates: false)
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
            self.present(controller, animated: true, completion: nil);
        }
    }
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        switch result.rawValue {
        case MessageComposeResult.cancelled.rawValue :
            print("message canceled")
            
        case MessageComposeResult.failed.rawValue :
            print("message failed")
            
        case MessageComposeResult.sent.rawValue :
            print("message sent")
            
        default:
            break
        }
        controller.dismiss(animated: true, completion: nil)
    }
    
    
    func shareToAll() {
        let textToShare = "Try download app UnPlanned! "
        
        if let myWebsite = URL(string: "http://www.codingexplorer.com/") {
            let objectsToShare = [textToShare, myWebsite] as [Any]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            
            activityVC.popoverPresentationController?.sourceView = self.view
            self.present(activityVC, animated: true, completion: nil)
        }
    }
    
    func openLegalUrl() {
        let url = URL(string: "https://google.com")!
        UIApplication.shared.openURL(url)
    }
}
    

