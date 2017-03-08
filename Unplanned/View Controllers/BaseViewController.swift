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
    func setupDevFacilityActionSheet(_ sheet:UIAlertController) {}
    
    func setupDevFacilities() {
        guard devFacilitiesEnabled && hasDevFacilities() else { return }
        view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(BaseViewController.devFacilityLongPress(_:))))
    }
    
    func devFacilityLongPress(_ gesture:UIGestureRecognizer) {
        if gesture.state == .began {
            
            let sheet = UIAlertController(title: "Dev Facility", message: "", preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            setupDevFacilityActionSheet(sheet)
            present(sheet, animated: true, completion: nil)
        }
    }
    
    func setupGradienNavigationBar(_ title : String){
        
        let nav = self.navigationController?.navigationBar
        
        let gradientLayer = CAGradientLayer()
        
        let frame = nav?.bounds
        gradientLayer.frame = CGRect(x: 0, y: 0, width: frame!.width, height: frame!.height-20)
        gradientLayer.colors = [UIColor(rgba: "#00B9CE"),UIColor(rgba: "#00B3E6")].map{$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Render the gradient to UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        nav?.tintColor = UIColor.white
        self.navigationItem.title = title
        nav?.titleTextAttributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]
        
        // Set the UIImage as background property
        nav?.setBackgroundImage(image, for: UIBarMetrics.default)
        nav?.isTranslucent = true

    }
    
    func setupSideMenu() {
            SideMenuManager.menuLeftNavigationController = storyboard!.instantiateViewController(withIdentifier: "LeftMenuNavigationController") as? UISideMenuNavigationController
            SideMenuManager.menuLeftNavigationController!.leftSide = true
            SideMenuManager.menuWidth = max(round(min(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.8), 240)
            SideMenuManager.menuPresentMode = .viewSlideInOut
            SideMenuManager.menuAnimationBackgroundColor = UIColor(rgba: "#F3FEFF")
            SideMenuManager.menuFadeStatusBar = false
            SideMenuManager.menuAnimationPresentDuration = 0.4
            SideMenuManager.menuAnimationDismissDuration = 0.4
            SideMenuManager.menuAnimationFadeStrength = 0.1
            SideMenuManager.menuShadowColor = UIColor.clear
            SideMenuManager.menuAnimationTransformScaleFactor = 1
            SideMenuManager.menuAddPanGestureToPresent(toView: self.navigationController!.navigationBar)
            SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: self.navigationController!.view)
    }
    
    func setTransparentNavigationBar(_ text : String? = nil) {

        let nav = self.navigationController?.navigationBar

        nav?.setBackgroundImage(UIImage(), for:UIBarMetrics.default)
        nav?.isTranslucent = true
        nav?.shadowImage = UIImage()
        self.navigationController?.setNavigationBarHidden(false, animated:true)

        nav?.tintColor = UIColor.white
        self.navigationItem.title = text
        nav?.titleTextAttributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]
    }
    
    func sendSMS(_ text : String, phoneNumber : String)
    {
        
        let twilioSID = "ACc55253da9bf15b10e6aa713b714a6be4"
        let twilioSecret = "81b82c4a9e8f8c8dc4053769d15952d5"
        
        //Note replace + = %2B , for To and From phone number
        let fromNumber = "%2B525549998293"// actual number is +14803606445
        let toNumber = phoneNumber.replacingOccurrences(of: "+", with: "%2B")
        
        // Build the request
        let request = NSMutableURLRequest(url: URL(string:"https://\(twilioSID):\(twilioSecret)@api.twilio.com/2010-04-01/Accounts/\(twilioSID)/Messages")!)
        request.httpMethod = "POST"
        request.httpBody = "From=\(fromNumber)&To=\(toNumber)&Body=\(text)".data(using: String.Encoding.utf8)
        
        // Build the completion block and send the request
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, error) in
            print("Finished")
            if let data = data, let responseDetails = NSString(data: data, encoding: String.Encoding.utf8) {
                // Success
                print("Response: \(responseDetails)")
            } else {
                // Failure
                print("Error: \(error)")
            }
        }).resume()
    }
    
    func timeFormat(_ sender: Date) -> String
    {
        let timeSave = DateFormatter() //Creating first object to update time label as 12hr format with AM/PM
        timeSave.timeStyle = DateFormatter.Style.short //Setting the style for the time selection.
        let timeCheck = DateFormatter() //Creating another object to store time in 24hr format.
        timeCheck.dateFormat = "h:mm a" //Setting the format for the time save.
        let time = timeCheck.string(from: sender) //Getting the time string as 13:40:00
        return time //At last saving the 24hr format time for further task.
    }

    
    func getContacts() -> [CNContact] {
        let contactStore = CNContactStore()
        var results: [CNContact] = []
        do {
            try contactStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor, CNContactPostalAddressesKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor])) {
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
