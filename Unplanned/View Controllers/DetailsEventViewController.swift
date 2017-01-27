//
//  DetailsEventViewController.swift
//  Unplanned
//
//  Created by matata on 31.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse

class DetailsEventViewController: BaseViewController {

    
    @IBOutlet weak var ivBackgrounPicture: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var ivUserPhoto: UIImageView!
    @IBOutlet weak var labelUserName: UILabel!
    @IBOutlet weak var labelLocationTitle: UILabel!
    @IBOutlet weak var labelLocationAddress: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelTime: UILabel!
    @IBOutlet weak var labelCountMembers: UILabel!
    @IBOutlet weak var buttonYes: UIButton!
    @IBOutlet weak var buttonNo: UIButton!
    
    
    var currentFeed : FeedListModel!
    
    @IBOutlet weak var labelAttending: UILabel!
    @IBOutlet weak var labelAttendingBottomConstraint: NSLayoutConstraint!

    @IBOutlet weak var openPeoplesEvent: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.labelAttending.text = "  " + "Attending".localized()
        self.buttonYes.setTitle("Yes".localized(), forState: .Normal)
        self.buttonNo.setTitle("No".localized(), forState: .Normal)

        self.buttonYes.hidden = self.currentFeed.isMyEvent
        self.buttonNo.hidden = self.currentFeed.isMyEvent
        self.labelAttending.hidden = self.currentFeed.isMyEvent

        if (self.currentFeed.isMyEvent) {
            self.labelAttendingBottomConstraint.constant = -self.labelAttending.frame.size.height
        }

        self.labelCountMembers.text = "\(self.currentFeed.members.count) \("Confirmed".localized())"
        
        self.ivBackgrounPicture.image = UIImage(named: "image_event_\(currentFeed.titleEvent.lowercaseString)")
        self.labelTitle.text = self.currentFeed.titleEvent.capitalizedString
        
        if self.currentFeed.user.photoUrl.characters.count > 0 {
            self.ivUserPhoto.kf_setImageWithURL(NSURL(string: self.currentFeed.user.photoUrl)!)
        }
        
        self.labelUserName.text = "\(self.currentFeed.user.valueForKey("name")!)"
        self.labelLocationTitle.text = self.currentFeed.locationTitleEvent
        self.labelLocationAddress.text = self.currentFeed.addressEvent
        
        let year = NSString(string: String(currentFeed.dateEvent.year)).substringFromIndex(2)
        labelDate.text = "\(currentFeed.dateEvent.monthName.capitalizedString) \(currentFeed.dateEvent.day) '\(year)"
        labelTime.text = "\(currentFeed.dateEvent.mt_stringFromDateWithShortWeekdayTitle()) - \(self.timeFormat(currentFeed.dateEvent).lowercaseString)"
        
        
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        self.setupGradienNavigationBar(self.currentFeed.titleEvent)
        self.createNavigationBarButtons()
        
        
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
        
    }
    
    func close(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    @IBAction func openPeoplesPressed(sender: AnyObject) {
        self.performSegueWithIdentifier("segueOpenDetailPeoples", sender: nil)
    }
    
    @IBAction func acceptPressed(sender: AnyObject) {
        if self.isMember() {
            let alert = UIAlertController(title: "Oops!", message:"Already accepted", preferredStyle: .Alert)
            let action = UIAlertAction(title: "Close", style: .Default) { _ in
                // Put here any code that you would like to execute when
                // the user taps that OK button (may be empty in your case if that's just
                // an informative alert)
            }
            alert.addAction(action)
            self.presentViewController(alert, animated: true){}
        }else {
            self.addMeAsMember()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueOpenDetailPeoples" {
            let destinationVC = segue.destinationViewController as! DetailEventPeoplesViewController
            let members = self.currentFeed.members
            destinationVC.listMembers = members
        }
        
        if segue.identifier == "segueOpenMapFromDetails" {
            let destinationVC = segue.destinationViewController as! MapViewController
            
            destinationVC.titleLocation = self.currentFeed.locationTitleEvent
            destinationVC.addressLocation = self.currentFeed.addressEvent
            destinationVC.addressLong = self.currentFeed.longitude
            destinationVC.adressLat = self.currentFeed.latitude
        }
    }
    @IBAction func declinePressed(sender: AnyObject) {
        removeMeAsMember()
    }

    func isMember () -> Bool {
        return self.currentFeed.members.containsObject((PFUser.currentUser()?.username)!)
    }

    func addMeAsMember() {
        self.hudShow()
        
        self.buttonNo.enabled = false
        self.buttonYes.enabled = false
        self.buttonNo.backgroundColor = UIColor(hex6 : 0xD8D8D8)
        self.buttonYes.backgroundColor = UIColor(hex6 : 0x00BDE1)
        self.buttonNo.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        self.buttonYes.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)

        let queryGetEvents = PFQuery(className: "Event")
        queryGetEvents.whereKey("objectId", equalTo : self.currentFeed.idEvent)
        queryGetEvents.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error: NSError?) in
            object?.addObject((PFUser.currentUser()?.username)!, forKey: "accepted_members")
            object?.saveInBackgroundWithBlock({ (done :Bool, error: NSError?) in
                self.navigationController?.popViewControllerAnimated(true)
                self.hudHide()
            })
        }
    }
    
    func removeMeAsMember() {
        self.hudShow()
        
        self.buttonNo.enabled = false
        self.buttonYes.enabled = false
        self.buttonNo.backgroundColor = UIColor(hex6 : 0x00BDE1)
        self.buttonYes.backgroundColor = UIColor(hex6 : 0xD8D8D8)
        self.buttonNo.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        self.buttonYes.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)

        let queryGetEvents = PFQuery(className: "Event")
        queryGetEvents.whereKey("objectId", equalTo : self.currentFeed.idEvent)
        queryGetEvents.getFirstObjectInBackgroundWithBlock { (object:PFObject?, error: NSError?) in
            object?.removeObject((PFUser.currentUser()?.username)!, forKey: "accepted_members")
            object?.removeObject((PFUser.currentUser()?.username)!, forKey: "participants")
            object?.saveInBackgroundWithBlock({ (done :Bool, error: NSError?) in
                self.navigationController?.popViewControllerAnimated(true)
                self.hudHide()
            })
        }
    }
    
   
    
    @IBAction func openMap(sender: AnyObject) {
        
            self.performSegueWithIdentifier("segueOpenMapFromDetails", sender: nil)
        
        
    }
}
