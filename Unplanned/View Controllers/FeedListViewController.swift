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
        self.segmentControl.setTitle("Invitations".localized(), forSegmentAt: 0)
        self.segmentControl.setTitle("Sent".localized(), forSegmentAt: 1)

        let titleTextAttributes = [NSForegroundColorAttributeName: UIColor.darkGray]
        self.segmentControl.setTitleTextAttributes(titleTextAttributes, for: .selected)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.getEvents()
        updateBadges()
        self.getEventsFromOther()
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
        
        let gradientLayer = CAGradientLayer()
        
        let frame = imageTop.bounds
        gradientLayer.frame = frame
        gradientLayer.colors = [UIColor(rgba: "#00B9CE"),UIColor(rgba: "#00B3E6")].map{$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        
        // Render the gradient to UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        imageTop.image = image
        
    }
    
    func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.activeListEvents.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedListTableViewCell") as! FeedListTableViewCell
        
        let currentItem = self.activeListEvents[indexPath.row]
        
        cell.labelTitleEvent.text = currentItem.titleEvent
        cell.labelExpired.layer.cornerRadius = 3
        cell.labelExpired.layer.masksToBounds = true

        let expired : Bool = currentItem.dateEvent.mt_oneHourNext() < Date()

        cell.labelExpired.isHidden = !expired

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

        let year = NSString(string: String(currentItem.dateEvent.year)).substring(from: 2)
        cell.labelDateEvent.text = "\(currentItem.dateEvent.monthName.capitalized) \(currentItem.dateEvent.day) '\(year)"
        
        cell.labelTimeEvent.text = "\(currentItem.dateEvent.mt_stringFromDateWithShortWeekdayTitle()) - \(self.timeFormat(currentItem.dateEvent).lowercased())"
        
        cell.labelAddressEvent.text = currentItem.locationTitleEvent

        cell.ivPhotoUser.kf_setImageWithURL(URL(string: currentItem.user.photoUrl ?? "")!)

        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        if segmentControl.selectedSegmentIndex == 1 {
            return true
        }
        else {
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
    
        let delete = UITableViewRowAction(style: .normal, title: "Delete".localized()) { action, index in
            
            let row = indexPath.row

            let event = self.eventLists[row]

            let query = PFQuery(className: "Event")
            query.whereKey("objectId", equalTo: event.idEvent)

            query.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) -> Void in

                if let objs = objects {
                    for object in objs {
                        object.deleteInBackground(block: { (value: Bool, error : NSError?) in
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
        delete.backgroundColor = UIColor.red

        return [delete]
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "segueOpenDetailsEvent", sender: indexPath.row)
    }
    
    func getEvents() {
        
        let queryGetEvents = PFQuery(className: "Event")
        queryGetEvents.whereKey("user", equalTo: PFUser.current()!)
        queryGetEvents.order(byDescending: "date")
        queryGetEvents.includeKey("user")
        
        queryGetEvents.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) in

            if error == nil {

                let realm = try! Realm()

                for object : PFObject in objects! {
            
                    var arrayUsers = NSArray()
                    
                    if let array = object.object(forKey: "accepted_members") as? NSArray {
                        arrayUsers = array
                    }

                    let user = object.object(forKey: "user") as! PFUser;

                    var imageUrl = ""

                    if let photo = user.object(forKey: "photo") as? PFFile {
                        imageUrl = photo.url!
                    }

                    let rUser = RealmUserModel(_objectId: user.objectId!, _userName: (user.value(forKey: "username") as! String), _name: "\(user.value(forKey: "firstName") as! String) \(user.value(forKey: "lastName") as! String)", _imageUrl: imageUrl, _isAdded : true)

                    try! realm.write {
                        realm.add(rUser, update: true)
                    }

                    let feed = FeedListModel(_idEvent: object.objectId!, _titleEvent: (object.value(forKey: "type") as! String).capitalized, _addressEvent: object.value(forKey: "location_address") as! String, _locationTitleEvent : object.value(forKey: "location_title") as! String, _isMyEvent: true, _user: rUser, _dateEvent: object.value(forKey: "date") as! Date, _members : arrayUsers, _coordinates : object.value(forKey: "coordinates") as! PFGeoPoint)

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
        queryGetEvents.whereKey("participants", containsAllObjectsIn : [(PFUser.current()?.username)!])
        queryGetEvents.order(byDescending: "date")
        queryGetEvents.includeKey("user")
        
        queryGetEvents.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) in
            if error == nil {

                let realm = try! Realm()

                for object : PFObject in objects! {
                    
                    var arrayUsers = NSArray()
                    
                    if let array = object.object(forKey: "accepted_members") as? NSArray {
                        arrayUsers = array
                    }
                    
                    if  let user = object.object(forKey: "user") as? PFUser {

                        var imageUrl = ""

                        if let photo = user.object(forKey: "photo") as? PFFile {
                            imageUrl = photo.url!
                        }

                        let rUser = RealmUserModel(_objectId: user.objectId!, _userName: (user.value(forKey: "username") as! String), _name: "\(user.value(forKey: "firstName") as! String) \(user.value(forKey: "lastName") as! String)", _imageUrl: imageUrl, _isAdded : true)

                        try! realm.write {
                            realm.add(rUser, update: true)
                        }

                        let feed = FeedListModel(_idEvent: object.objectId!, _titleEvent: object.value(forKey: "type") as! String, _addressEvent: object.value(forKey: "location_address") as! String, _locationTitleEvent : object.value(forKey: "location_title") as! String, _isMyEvent: false, _user: rUser, _dateEvent: object.object(forKey: "date") as! Date,  _members : arrayUsers, _coordinates : object.value(forKey: "coordinates") as! PFGeoPoint)

                        try! realm.write {
                            realm.add(feed, update: true)
                        }
                    }
                }

               self.fragmentChanged("")
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueOpenDetailsEvent" {
            let destinationVC = segue.destination as! DetailsEventViewController
            let row = sender as! Int
            destinationVC.currentFeed = self.activeListEvents[row]
        }
    }
    
    @IBAction func fragmentChanged(_ sender: AnyObject) {
        
        
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
