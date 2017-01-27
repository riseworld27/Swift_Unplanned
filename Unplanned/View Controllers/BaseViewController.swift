//
//  BaseViewController.swift
//  Unplanned
//
//  Created by True Metal on 5/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import UIColor_Hex_Swift
import SideMenu
import QuadratTouch
import Contacts

class BaseViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDevFacilities()
    }
    
    func hudShow() { Unplanned.hudShow(view) }
    func hudHide() { Unplanned.hudHide(view) }
    
    // MARK: dev facilities

    // to be overriden
    func hasDevFacilities() -> Bool { return false }
    func setupDevFacilityActionSheet(sheet:UIAlertController) {}
    
    func setupDevFacilities() {
        guard devFacilitiesEnabled && hasDevFacilities() else { return }
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(BaseViewController.devFacilityLongPress(_:))))
    }
    
    func devFacilityLongPress(gesture:UIGestureRecognizer) {
        if gesture.state == .Began {
            
            let sheet = UIAlertController(title: "Dev Facility", message: "", preferredStyle: .ActionSheet)
            sheet.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            setupDevFacilityActionSheet(sheet)
            presentViewController(sheet, animated: true, completion: nil)
        }
    }
    
    func setupGradienNavigationBar(title : String){
        
        let nav = self.navigationController?.navigationBar
        
        let gradientLayer = CAGradientLayer()
        
        let frame = nav?.bounds
        gradientLayer.frame = CGRectMake(0, 0, frame!.width, frame!.height-20)
        gradientLayer.colors = [UIColor(rgba: "#00B9CE"),UIColor(rgba: "#00B3E6")].map{$0.CGColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Render the gradient to UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        nav?.tintColor = UIColor.whiteColor()
        self.navigationItem.title = title
        nav?.titleTextAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Set the UIImage as background property
        nav?.setBackgroundImage(image, forBarMetrics: UIBarMetrics.Default)
        nav?.translucent = true

    }
    
    func setupSideMenu() {
            SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewControllerWithIdentifier("LeftMenuNavigationController") as? UISideMenuNavigationController
            SideMenuManager.menuLeftNavigationController!.leftSide = true
            SideMenuManager.menuWidth = max(round(min(UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height) * 0.8), 240)
            SideMenuManager.menuPresentMode = .ViewSlideInOut
            SideMenuManager.menuAnimationBackgroundColor = UIColor(rgba: "#F3FEFF")
            SideMenuManager.menuFadeStatusBar = false
            SideMenuManager.menuAnimationPresentDuration = 0.4
            SideMenuManager.menuAnimationDismissDuration = 0.4
            SideMenuManager.menuAnimationFadeStrength = 0.1
            SideMenuManager.menuShadowColor = UIColor.clearColor()
            SideMenuManager.menuAnimationTransformScaleFactor = 1
            SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
            SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
    }
    
    func setTransparentNavigationBar(text : String? = nil) {

        let nav = self.navigationController?.navigationBar

        nav?.setBackgroundImage(UIImage(), forBarMetrics:UIBarMetrics.Default)
        nav?.translucent = true
        nav?.shadowImage = UIImage()
        self.navigationController?.setNavigationBarHidden(false, animated:true)

        nav?.tintColor = UIColor.whiteColor()
        self.navigationItem.title = text
        nav?.titleTextAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func sendSMS(text : String, phoneNumber : String)
    {
        
        let twilioSID = "ACc55253da9bf15b10e6aa713b714a6be4"
        let twilioSecret = "81b82c4a9e8f8c8dc4053769d15952d5"
        
        //Note replace + = %2B , for To and From phone number
        let fromNumber = "%2B525549998293"// actual number is +14803606445
        let toNumber = phoneNumber.stringByReplacingOccurrencesOfString("+", withString: "%2B")
        
        // Build the request
        let request = NSMutableURLRequest(URL: NSURL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/Messages")!)
        request.HTTPMethod = "POST"
        request.HTTPBody = "From=\(fromNumber)&To=\(toNumber)&Body=\(text)".dataUsingEncoding(NSUTF8StringEncoding)
        
        // Build the completion block and send the request
        NSURLSession.sharedSession().dataTaskWithRequest(request, completionHandler: { (data, response, error) in
            print("Finished")
            if let data = data, responseDetails = NSString(data: data, encoding: NSUTF8StringEncoding) {
                // Success
                print("Response: \(responseDetails)")
            } else {
                // Failure
                print("Error: \(error)")
            }
        }).resume()
    }
    
    func timeFormat(sender: NSDate) -> String
    {
        let timeSave = NSDateFormatter() //Creating first object to update time label as 12hr format with AM/PM
        timeSave.timeStyle = NSDateFormatterStyle.ShortStyle //Setting the style for the time selection.
        let timeCheck = NSDateFormatter() //Creating another object to store time in 24hr format.
        timeCheck.dateFormat = "h:mm a" //Setting the format for the time save.
        let time = timeCheck.stringFromDate(sender) //Getting the time string as 13:40:00
        return time //At last saving the 24hr format time for further task.
    }

    
    func getContacts() -> [CNContact] {
        let contactStore = CNContactStore()
        var results: [CNContact] = []
        do {
            try contactStore.enumerateContactsWithFetchRequest(CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactImageDataKey, CNContactImageDataAvailableKey])) {
                (contact, cursor) -> Void in
                results.append(contact)
            }
        }
        catch{
            print("Handle the error please")
        }
        return results
    }
}
