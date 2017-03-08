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
        self.buttonYes.setTitle("Yes".localized(), for: UIControlState())
        self.buttonNo.setTitle("No".localized(), for: UIControlState())

        self.buttonYes.isHidden = self.currentFeed.isMyEvent
        self.buttonNo.isHidden = self.currentFeed.isMyEvent
        self.labelAttending.isHidden = self.currentFeed.isMyEvent

        if (self.currentFeed.isMyEvent) {
            self.labelAttendingBottomConstraint.constant = -self.labelAttending.frame.size.height
        }

        self.labelCountMembers.text = "\(self.currentFeed.members.count) \("Confirmed".localized())"
        
        self.ivBackgrounPicture.image = UIImage(named: "image_event_\(currentFeed.titleEvent.lowercased())")
        self.labelTitle.text = self.currentFeed.titleEvent.capitalized
        
        if self.currentFeed.user.photoUrl.characters.count > 0 {
            self.ivUserPhoto.kf_setImageWithURL(URL(string: self.currentFeed.user.photoUrl)!)
        }
        
        self.labelUserName.text = "\(self.currentFeed.user.value(forKey: "name")!)"
        self.labelLocationTitle.text = self.currentFeed.locationTitleEvent
        self.labelLocationAddress.text = self.currentFeed.addressEvent
        
        let year = NSString(string: String(currentFeed.dateEvent.year)).substring(from: 2)
        labelDate.text = "\(currentFeed.dateEvent.monthName.capitalized) \(currentFeed.dateEvent.day) '\(year)"
        labelTime.text = "\(currentFeed.dateEvent.mt_stringFromDateWithShortWeekdayTitle()) - \(self.timeFormat(currentFeed.dateEvent).lowercased())"
        
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupGradienNavigationBar(self.currentFeed.titleEvent)
        self.createNavigationBarButtons()
        
        
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
        
    }
    
    func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func openPeoplesPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueOpenDetailPeoples", sender: nil)
    }
    
    @IBAction func acceptPressed(_ sender: AnyObject) {
        if self.isMember() {
            let alert = UIAlertController(title: "Oops!", message:"Already accepted", preferredStyle: .alert)
            let action = UIAlertAction(title: "Close", style: .default) { _ in
                // Put here any code that you would like to execute when
                // the user taps that OK button (may be empty in your case if that's just
                // an informative alert)
            }
            alert.addAction(action)
            self.present(alert, animated: true){}
        }else {
            self.addMeAsMember()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueOpenDetailPeoples" {
            let destinationVC = segue.destination as! DetailEventPeoplesViewController
            let members = self.currentFeed.members
            destinationVC.listMembers = members
        }
        
        if segue.identifier == "segueOpenMapFromDetails" {
            let destinationVC = segue.destination as! MapViewController
            
            destinationVC.titleLocation = self.currentFeed.locationTitleEvent
            destinationVC.addressLocation = self.currentFeed.addressEvent
            destinationVC.addressLong = self.currentFeed.longitude
            destinationVC.adressLat = self.currentFeed.latitude
        }
    }
    @IBAction func declinePressed(_ sender: AnyObject) {
        removeMeAsMember()
    }

    func isMember () -> Bool {
        return self.currentFeed.members.contains((PFUser.current()?.username)!)
    }

    func addMeAsMember() {
        self.hudShow()
        
        self.buttonNo.isEnabled = false
        self.buttonYes.isEnabled = false
        self.buttonNo.backgroundColor = UIColor(hex6 : 0xD8D8D8)
        self.buttonYes.backgroundColor = UIColor(hex6 : 0x00BDE1)
        self.buttonNo.setTitleColor(UIColor.black, for: UIControlState())
        self.buttonYes.setTitleColor(UIColor.white, for: UIControlState())

        let queryGetEvents = PFQuery(className: "Event")
        queryGetEvents.whereKey("objectId", equalTo : self.currentFeed.idEvent)
        queryGetEvents.getFirstObjectInBackground { (object:PFObject?, error: NSError?) in
            object?.add((PFUser.current()?.username)!, forKey: "accepted_members")
            object?.saveInBackground(block: { (done :Bool, error: NSError?) in
                self.navigationController?.popViewController(animated: true)
                self.hudHide()
            })
        }
    }
    
    func removeMeAsMember() {
        self.hudShow()
        
        self.buttonNo.isEnabled = false
        self.buttonYes.isEnabled = false
        self.buttonNo.backgroundColor = UIColor(hex6 : 0x00BDE1)
        self.buttonYes.backgroundColor = UIColor(hex6 : 0xD8D8D8)
        self.buttonNo.setTitleColor(UIColor.white, for: UIControlState())
        self.buttonYes.setTitleColor(UIColor.black, for: UIControlState())

        let queryGetEvents = PFQuery(className: "Event")
        queryGetEvents.whereKey("objectId", equalTo : self.currentFeed.idEvent)
        queryGetEvents.getFirstObjectInBackground { (object:PFObject?, error: NSError?) in
            object?.remove((PFUser.current()?.username)!, forKey: "accepted_members")
            object?.remove((PFUser.current()?.username)!, forKey: "participants")
            object?.saveInBackground(block: { (done :Bool, error: NSError?) in
                self.navigationController?.popViewController(animated: true)
                self.hudHide()
            })
        }
    }
    
   
    
    @IBAction func openMap(_ sender: AnyObject) {
        
            self.performSegue(withIdentifier: "segueOpenMapFromDetails", sender: nil)
        
        
    }
}
