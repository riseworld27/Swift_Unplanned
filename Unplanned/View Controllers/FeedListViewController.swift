//
//  FeedListViewController.swift
//  Unplanned
//
//  Created by matata on 30.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import Kingfisher
import SwiftDate
import MTDates
import RealmSwift

class FeedListViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {

    lazy var eventLists : Results<FeedListModel> = {
        let realm = try! Realm()
        return realm.objects(FeedListModel.self).filter("isMyEvent = true")
    }()
    lazy var eventListInvited : Results<FeedListModel> = {
        let realm = try! Realm()
        return realm.objects(FeedListModel.self).filter("isMyEvent = false")
    }()

    lazy var activeListEvents : Results<FeedListModel> = {

        switch self.segmentControl.selectedSegmentIndex {
        case 0:
            return self.eventListInvited
            break
        case 1:
            return self.eventLists
            break
        default:
            return self.eventListInvited
            break;
        }
    }()

    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageTop: UIImageView!
    override func viewDidLoad() {
        self.setupGradienNavigationBar("Feed".localized())
        self.createNavigationBarButtons()
        self.segmentControl.setTitle("Invitations".localized(), forSegmentAtIndex: 0)
        self.segmentControl.setTitle("Sent".localized(), forSegmentAtIndex: 1)

        let titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGrayColor()]
        self.segmentControl.setTitleTextAttributes(titleTextAttributes, forState: .Selected)
    }
    
    override func viewWillAppear(animated: Bool) {
        self.getEvents()
        updateBadges()
        self.getEventsFromOther()
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
        
        let gradientLayer = CAGradientLayer()
        
        let frame = imageTop.bounds
        gradientLayer.frame = frame
        gradientLayer.colors = [UIColor(rgba: "#00B9CE"),UIColor(rgba: "#00B3E6")].map{$0.CGColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Render the gradient to UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageTop.image = image
        
    }
    
    func close(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activeListEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("FeedListTableViewCell") as! FeedListTableViewCell
        
        let currentItem = self.activeListEvents[indexPath.row]
        
        cell.labelTitleEvent.text = currentItem.titleEvent
        cell.labelExpired.layer.cornerRadius = 3
        cell.labelExpired.layer.masksToBounds = true

        let expired : Bool = currentItem.dateEvent.mt_oneHourNext() < NSDate()

        cell.labelExpired.hidden = !expired

        if (expired) {
            cell.labelTitleEvent.textColor = UIColor(hex6: 0xFF7575)
            cell.labelAddressEvent.textColor = UIColor(hex6: 0xFF7575)
            cell.labelDateEvent.textColor = UIColor(hex6: 0xFF7575)
            cell.labelTimeEvent.textColor = UIColor(hex6: 0xFF7575)
        } else {
            cell.labelTitleEvent.textColor = UIColor(hex6: 0x00BDE1)
            cell.labelAddressEvent.textColor = UIColor(hex6: 0x8F8E94)
            cell.labelDateEvent.textColor = UIColor(hex6: 0x8F8E94)
            cell.labelTimeEvent.textColor = UIColor(hex6: 0x8F8E94)
        }

        let year = NSString(string: String(currentItem.dateEvent.year)).substringFromIndex(2)
        cell.labelDateEvent.text = "\(currentItem.dateEvent.monthName.capitalizedString) \(currentItem.dateEvent.day) '\(year)"
        
        cell.labelTimeEvent.text = "\(currentItem.dateEvent.mt_stringFromDateWithShortWeekdayTitle()) - \(self.timeFormat(currentItem.dateEvent).lowercaseString)"
        
        cell.labelAddressEvent.text = currentItem.locationTitleEvent

        cell.ivPhotoUser.kf_setImageWithURL(NSURL(string: currentItem.user.photoUrl ?? "")!)

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if segmentControl.selectedSegmentIndex == 1 {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
    
        let delete = UITableViewRowAction(style: .Normal, title: "Delete".localized()) { action, index in
            
            let row = indexPath.row

            let event = self.eventLists[row]

            let query = PFQuery(className: "Event")
            query.whereKey("objectId", equalTo: event.idEvent)

            query.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) -> Void in

                if let objs = objects {
                    for object in objs {
                        object.deleteInBackgroundWithBlock({ (value: Bool, error : NSError?) in
                            if value == false {

                                self.getEvents()
                            }
                        })
                    }
                }
            }

            let realm = try! Realm()

            try! realm.write {
                realm.delete(event)
            }

            self.tableView.reloadData()
        }
        delete.backgroundColor = UIColor.redColor()

        return [delete]
    }

    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("segueOpenDetailsEvent", sender: indexPath.row)
    }
    
    func getEvents() {
        
        let queryGetEvents = PFQuery(className: "Event")
        queryGetEvents.whereKey("user", equalTo: PFUser.currentUser()!)
        queryGetEvents.orderByDescending("date")
        queryGetEvents.includeKey("user")
        
        queryGetEvents.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) in

            if error == nil {

                let realm = try! Realm()

                for object : PFObject in objects! {
            
                    var arrayUsers = NSArray()
                    
                    if let array = object.objectForKey("accepted_members") as? NSArray {
                        arrayUsers = array
                    }

                    let user = object.objectForKey("user") as! PFUser;

                    var imageUrl = ""

                    if let photo = user.objectForKey("photo") as? PFFile {
                        imageUrl = photo.url!
                    }

                    let rUser = RealmUserModel(_objectId: user.objectId!, _userName: (user.valueForKey("username") as! String), _name: "\(user.valueForKey("firstName") as! String) \(user.valueForKey("lastName") as! String)", _imageUrl: imageUrl, _isAdded : true)

                    try! realm.write {
                        realm.add(rUser, update: true)
                    }

                    let feed = FeedListModel(_idEvent: object.objectId!, _titleEvent: (object.valueForKey("type") as! String).capitalizedString, _addressEvent: object.valueForKey("location_address") as! String, _locationTitleEvent : object.valueForKey("location_title") as! String, _isMyEvent: true, _user: rUser, _dateEvent: object.valueForKey("date") as! NSDate, _members : arrayUsers, _coordinates : object.valueForKey("coordinates") as! PFGeoPoint)

                    try! realm.write {
                        realm.add(feed, update: true)
                    }
                }

            self.fragmentChanged("")

            }
        }
    }
    
    func getEventsFromOther() {
        
        let queryGetEvents = PFQuery(className: "Event")
        queryGetEvents.whereKey("participants", containsAllObjectsInArray : [(PFUser.currentUser()?.username)!])
        queryGetEvents.orderByDescending("date")
        queryGetEvents.includeKey("user")
        
        queryGetEvents.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) in
            if error == nil {

                let realm = try! Realm()

                for object : PFObject in objects! {
                    
                    var arrayUsers = NSArray()
                    
                    if let array = object.objectForKey("accepted_members") as? NSArray {
                        arrayUsers = array
                    }
                    
                    if  let user = object.objectForKey("user") as? PFUser {

                        var imageUrl = ""

                        if let photo = user.objectForKey("photo") as? PFFile {
                            imageUrl = photo.url!
                        }

                        let rUser = RealmUserModel(_objectId: user.objectId!, _userName: (user.valueForKey("username") as! String), _name: "\(user.valueForKey("firstName") as! String) \(user.valueForKey("lastName") as! String)", _imageUrl: imageUrl, _isAdded : true)

                        try! realm.write {
                            realm.add(rUser, update: true)
                        }

                        let feed = FeedListModel(_idEvent: object.objectId!, _titleEvent: object.valueForKey("type") as! String, _addressEvent: object.valueForKey("location_address") as! String, _locationTitleEvent : object.valueForKey("location_title") as! String, _isMyEvent: false, _user: rUser, _dateEvent: object.objectForKey("date") as! NSDate,  _members : arrayUsers, _coordinates : object.valueForKey("coordinates") as! PFGeoPoint)

                        try! realm.write {
                            realm.add(feed, update: true)
                        }
                    }
                }

               self.fragmentChanged("")
            }
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueOpenDetailsEvent" {
            let destinationVC = segue.destinationViewController as! DetailsEventViewController
            let row = sender as! Int
            destinationVC.currentFeed = self.activeListEvents[row]
        }
    }
    
    @IBAction func fragmentChanged(sender: AnyObject) {
        
        
        switch self.segmentControl.selectedSegmentIndex
        {
        case 0:
            self.activeListEvents = self.eventListInvited
            break
        case 1:
            self.activeListEvents = self.eventLists
            break
        default:
            break; 
        }
        
        self.tableView.reloadData()
    }
}
