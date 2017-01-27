//  CreateEventViewController.swift
//  Unplanned
//
//  Created by matata on 29.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import PageMenu
import UIColor_Hex_Swift
import Parse
import Contacts

class CreateEventViewController: BaseViewController {

    @IBOutlet weak var tabLocation: UIView!
    @IBOutlet weak var tabDate: UIView!
    @IBOutlet weak var tabGroups: UIView!
    @IBOutlet weak var tabLocationImage: UIImageView!
    @IBOutlet weak var tabDateImage: UIImageView!
    @IBOutlet weak var tabGroupsImage: UIImageView!
    
    //labels
    
    var friendsList = [String]()
    
    @IBOutlet weak var labelWhere: UILabel!
    @IBOutlet weak var labelWho: UILabel!
    
    @IBOutlet weak var labelWhen: UILabel!
    
    var listOfContacts = [CNContact]()
    
    var arrayOfNumbers = [String]()
    
    var controllerLocation:EventLocationViewController!
    var controllerDate : EventDateViewController!
    var controllerGroup : EventGroupViewController!
    
    var backgroundImage : UIImage!
    var titleText : String!
    var typeOfEvent : String!
    var foursquareId : String!
    
    @IBOutlet weak var ivCreateEvent: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    
    var pageMenu : CAPSPageMenu?
    
    override func viewDidLoad() {
        self.createNavigationBarButtons()
        
        self.labelWhere.text = "¿\("Where".localized())?" 
        self.labelWhen.text = "¿\("When".localized())?"
        self.labelWho.text = "¿\("Who".localized())?"
        
        tabLocation.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateEventViewController.pressedLocation(_:))))
        tabDate.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateEventViewController.pressedDate(_:))))
        tabGroups.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CreateEventViewController.pressedGroups(_:))))
        controllerLocation = self.storyboard!.instantiateViewControllerWithIdentifier("EventLocationViewController") as! EventLocationViewController
        controllerGroup = self.storyboard!.instantiateViewControllerWithIdentifier("EventGroupViewController") as! EventGroupViewController
        controllerDate = self.storyboard!.instantiateViewControllerWithIdentifier("EventDateViewController") as! EventDateViewController
        
        controllerLocation.foursquareId = self.foursquareId
        
        addLocationController()
        
        self.labelTitle.text = titleText.capitalizedString.localized()
        self.ivCreateEvent.image = backgroundImage
    }
    
    
    
    func addLocationController(){
        if (controllerDate != nil) {
            controllerDate.view.removeFromSuperview()
            controllerDate.removeFromParentViewController()
        }
        if (controllerLocation != nil) {
        controllerLocation.view.removeFromSuperview()
        controllerLocation.removeFromParentViewController()
        }
        
        if (controllerGroup != nil) {
        controllerGroup.view.removeFromSuperview()
        controllerGroup.removeFromParentViewController()
        }
        
        
        controllerLocation.view.frame = CGRectMake(0, 320, self.view.width(), self.view.height() - 320);
        controllerLocation.willMoveToParentViewController(self)
        self.view.insertSubview(controllerLocation.view, belowSubview: tabLocation)
        self.addChildViewController(controllerLocation)
        controllerLocation.didMoveToParentViewController(self)
    }
    
    func loadFriends() {
        
        self.friendsList.removeAll()

        let user = PFUser.currentUser()

        user?.fetchInBackground()

        self.friendsList = (user?.objectForKey("allFriends") as? [String]) ?? []
    }
    
    func addDateController(){
        if (controllerLocation != nil) {
        controllerLocation.view.removeFromSuperview()
        controllerLocation.removeFromParentViewController()
        }
        if (controllerGroup != nil) {
        controllerGroup.view.removeFromSuperview()
        controllerGroup.removeFromParentViewController()
        }
        
        controllerDate.view.frame = CGRectMake(0, 320, self.view.width(), self.view.height() - 320);
        controllerDate.willMoveToParentViewController(self)
        self.view.insertSubview(controllerDate.view, belowSubview: tabLocation)
        self.addChildViewController(controllerDate)
        controllerDate.didMoveToParentViewController(self)
    }
    
    func addGroupController() {
        if (controllerLocation != nil) {
        controllerLocation.view.removeFromSuperview()
        controllerLocation.removeFromParentViewController()
        }
        if (controllerDate != nil) {
        controllerDate.view.removeFromSuperview()
        controllerDate.removeFromParentViewController()
        }
        
        //controller.ANYPROPERTY=THEVALUE // If you want to pass value
        controllerGroup.view.frame = CGRectMake(0, 320, self.view.width(), self.view.height() - 320);
        controllerGroup.willMoveToParentViewController(self)
        self.view.insertSubview(controllerGroup.view, belowSubview: tabLocation)
        self.addChildViewController(controllerGroup)
        controllerGroup.didMoveToParentViewController(self)

    }
    
    
    func createNavigationBarButtons(){
        var menuImage:UIImage = UIImage(named: "icon_close_event")!
        
        menuImage = menuImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let menuButton: UIButton = UIButton(frame: CGRectMake(20, 20, 25, 25))
        menuButton.setImage(menuImage, forState: .Normal)
        menuButton.setImage(menuImage, forState: .Highlighted)
        menuButton.addTarget(self, action: #selector(CreateEventViewController.close(_:)), forControlEvents:.TouchUpInside)
        let menuButtonBar = UIBarButtonItem.init(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuButtonBar
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventViewController.submit(_:)))

        
    }
    
    func close(sender: UIButton) {
        self.setTransparentNavigationBar()
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func submit(sender : UIButton) {
        self.getDetailsOFGroup()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadFriends()
        self.setupGradienNavigationBar("Create Event".localized())
    }
    
    func pressedLocation(sender : UITapGestureRecognizer) {
        tabLocation.backgroundColor = UIColor(rgba: "#00BEE0")
        tabDate.backgroundColor = UIColor(rgba: "#3b3b3b")
        tabGroups.backgroundColor = UIColor(rgba: "#3b3b3b")
        
        tabLocationImage.image = UIImage(named: "icon_event_location_active")
        tabDateImage.image = UIImage(named: "icon_event_date_inactive")
        tabGroupsImage.image = UIImage(named: "icon_event_group_inactive")
        
        self.addLocationController()
        
        
    }
    
    func pressedDate(sender : UITapGestureRecognizer) {
        
        
        tabLocation.backgroundColor = UIColor(rgba: "#3b3b3b")
        tabDate.backgroundColor = UIColor(rgba: "#00BEE0")
        tabGroups.backgroundColor = UIColor(rgba: "#3b3b3b")
        
        tabLocationImage.image = UIImage(named: "icon_event_location_inactive")
        tabDateImage.image = UIImage(named: "icon_event_date_active")
        tabGroupsImage.image = UIImage(named: "icon_event_group_inactive")
        self.addDateController()
    }
    
    func pressedGroups(sender : UITapGestureRecognizer) {
        
        tabLocation.backgroundColor = UIColor(rgba: "#3b3b3b")
        tabDate.backgroundColor = UIColor(rgba: "#3b3b3b")
        tabGroups.backgroundColor = UIColor(rgba: "#00BEE0")
        
        tabLocationImage.image = UIImage(named: "icon_event_location_inactive")
        tabDateImage.image = UIImage(named: "icon_event_date_inactive")
        tabGroupsImage.image = UIImage(named: "icon_event_group_active")
        self.addGroupController()
    }
    
    func createEvent() {
        
        
        self.hudShow()
        let objectEvent = PFObject(className: "Event")
        
        objectEvent.setValue(controllerLocation.labelTitleLocation.text, forKey: "location_title")
        objectEvent.setValue(controllerLocation.labelDescriptionLocation.text, forKey: "location_address")
        objectEvent.setValue(controllerDate.selectedDate, forKey: "date")
        objectEvent.setValue(PFGeoPoint(latitude: controllerLocation.currentCoordinates.latitude , longitude: controllerLocation.currentCoordinates.longitude), forKey: "coordinates")
        objectEvent.addObject((PFUser.currentUser()?.username)!, forKey: "accepted_members")
        objectEvent.setValue(controllerGroup.inviteAll, forKey: "invite_all")
        objectEvent.setObject(self.arrayOfNumbers, forKey: "participants")
        objectEvent.setValue(self.typeOfEvent, forKey: "type")
        objectEvent.setObject(PFUser.currentUser()!, forKey: "user")
        objectEvent.saveInBackgroundWithBlock { (done: Bool, error: NSError?) -> Void in
            if error == nil {
                var name = ""
                
                if let fName = PFUser.currentUser()!.valueForKey("firstName") as? String {
                    name = fName
                    if let lName = PFUser.currentUser()!.valueForKey("lastName") as? String {
                        name.appendContentsOf(" \(lName)")
                    }
                }
                for number in self.arrayOfNumbers {
                    
                    if (self.friendsList.contains(number)) {
                    
                    sendPushNotificationToUser(number, title: "Invition", message: "\(name.capitalizedString) wants to go to \(self.typeOfEvent) with you \(self.timeFormat(self.controllerDate.selectedDate)) \(self.controllerDate.selectedDate.mt_stringValueWithDateStyle(.MediumStyle, timeStyle: .NoStyle)) in \(self.controllerLocation.labelTitleLocation.text!). Click http://google.com to confirm. Download UnPlanned app now http://google.com", pushType: "message")
                    } else {
                    
                    self.sendSMS("\(name.capitalizedString) wants to go to \(self.typeOfEvent) with you \(self.timeFormat(self.controllerDate.selectedDate)) \(self.controllerDate.selectedDate.mt_stringValueWithDateStyle(.MediumStyle, timeStyle: .NoStyle)) in \(self.controllerLocation.labelTitleLocation.text!). Click http://google.com to confirm. Download UnPlanned app now http://google.com", phoneNumber: number)
                    }
                }
                
            }
            self.navigationController?.popViewControllerAnimated(true)
            self.hudHide()
        }
    }
    
    func getDetailsOFGroup() {
        
        if (controllerLocation.labelTitleLocation.text == "" || controllerDate.selectedDate == nil || controllerGroup.selectedGroups.isEmpty || controllerLocation.currentCoordinates == nil) {
            return
        }
        
        if (controllerGroup.inviteAll) {
            self.listOfContacts = self.getContacts()
            
            
            var name = ""
            
            if let fName = PFUser.currentUser()!.valueForKey("firstName") as? String {
                name = fName
                if let lName = PFUser.currentUser()!.valueForKey("lastName") as? String {
                    name.appendContentsOf(" \(lName)")
                }
            }
            self.arrayOfNumbers.removeAll()
            for contact : CNContact in listOfContacts {
                
                
                var phoneStr = ""
                if contact.phoneNumbers.count > 0 {
                    let number = contact.phoneNumbers[0].value as! CNPhoneNumber
                    phoneStr = number.valueForKey("digits") as! String
                    
                    if !phoneStr.containsString("+") {
                        phoneStr = "+52\(phoneStr)"
                    }
                    
                    self.arrayOfNumbers.append(phoneStr)
                    
                }
            }
            self.createEvent()
            return
        }
        
        var idGroups = [String]()
        
        for group:GroupModel in controllerGroup.selectedGroups {
            idGroups.append(group.idGroup)
        }
        
        let queryGetEvents = PFQuery(className: "Group_users")
        queryGetEvents.whereKey("group_id", containedIn: idGroups)
        queryGetEvents.orderByDescending("full_name")
        queryGetEvents.includeKey("user")
        
          queryGetEvents.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) in
            if error == nil {
                self.arrayOfNumbers.removeAll()
                for object : PFObject in objects! {
                    
                    self.arrayOfNumbers.append(object.valueForKey("username") as! String)
                }
                self.createEvent()
                
            }
            
        }

    }
    
}
