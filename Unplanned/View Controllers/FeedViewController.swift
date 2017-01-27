//
//  FeedViewController.swift
//  Unplanned
//
//  Created by matata on 28.05.16.
//  Copyright © 2016 matata. All rights reserved.
//
import Foundation
import UIKit
import SideMenu
import DBBadgeLabel
import JSQNotificationObserverKit

class FeedViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    var listOfFeeds : [FeedModel]! = nil

    var badgeObserver: NotificationObserver<Any?, AnyObject>?

    override func viewDidLoad() {
        
        //self.sendSMS("Hi Alex", phoneNumber: "+79897151198")

        self.setupSideMenu()
        
        self.listOfFeeds = self.createList()
        
        var menuImage:UIImage = UIImage(named: "icon_menu")!
        
        menuImage = menuImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let menuButton: UIButton = UIButton(frame: CGRectMake(20, 20, 25, 25))
        menuButton.setImage(menuImage, forState: .Normal)
        menuButton.setImage(menuImage, forState: .Highlighted)
        menuButton.addTarget(self, action: #selector(FeedViewController.menu(_:)), forControlEvents:.TouchUpInside)

        let badge: DBBadgeLabel = DBBadgeLabel(cornerRadius: 9, textColor: UIColor.whiteColor(), backgroundColor: UIColor(hex6:0x672890))
        badge.text = "\(UIApplication.sharedApplication().applicationIconBadgeNumber)"
        badge.font = UIFont.systemFontOfSize(9)
        badge.textAlignment = NSTextAlignment.Center
        badge.frame = CGRectMake(25, -3, 18, 18)
        badge.hidden = UIApplication.sharedApplication().applicationIconBadgeNumber == 0
        menuButton.addSubview(badge)

        let menuButtonBar = UIBarButtonItem.init(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuButtonBar
        
        self.tableView.contentInset = UIEdgeInsets(top: 100,left: 0,bottom: 0,right: 0)

        badgeObserver = NotificationObserver(NotificationsHelper.badgeNotification) {

            (value, sender) in

            badge.hidden = UIApplication.sharedApplication().applicationIconBadgeNumber == 0
            badge.text = "\(UIApplication.sharedApplication().applicationIconBadgeNumber)"
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        self.setTransparentNavigationBar("What do you want to do?".localized())
    }
    
    func menu(sender: UIButton){
        let vc = SideMenuManager.menuLeftNavigationController
        self.presentViewController(vc!, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfFeeds.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("feedTableViewCell", forIndexPath: indexPath) as! FeedTableViewCell
        
        let row = indexPath.row
        
        
        cell.ivImageFeed.image = UIImage(named: self.listOfFeeds[row].imageIconName)
        cell.labelTitle.text = self.listOfFeeds[row].title
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("segueCreateEvent", sender: indexPath.row)
    }
    
    func createList() -> [FeedModel] {
        
        var listOfFeeds = [FeedModel]()
        
        listOfFeeds.append(FeedModel(_title: "Breakfast".localized(), _imageIconName: "icon_feed_breakfast", _imageBackgroundName: "image_event_breakfast", _type: "breakfast", _foursquareId: "breakfast"))
        listOfFeeds.append(FeedModel(_title: "Lunch".localized(), _imageIconName: "icon_feed_lunch", _imageBackgroundName: "image_event_lunch", _type: "lunch", _foursquareId: "lunch"))
        listOfFeeds.append(FeedModel(_title: "Dinner".localized(), _imageIconName: "icon_feed_dinner", _imageBackgroundName: "image_event_dinner", _type: "dinner", _foursquareId: "dinner"))
        listOfFeeds.append(FeedModel(_title: "Drinks".localized(), _imageIconName: "icon_feed_drinks", _imageBackgroundName: "image_event_drinks", _type: "drinks", _foursquareId: "drinks"))
        listOfFeeds.append(FeedModel(_title: "Party".localized(), _imageIconName: "icon_feed_party", _imageBackgroundName: "image_event_party", _type: "party", _foursquareId: "party"))
        listOfFeeds.append(FeedModel(_title: "Nightclub".localized(), _imageIconName: "icon_feed_nightclub", _imageBackgroundName: "image_event_nightclub", _type: "nightclub", _foursquareId: "nightclub"))
        listOfFeeds.append(FeedModel(_title: "Movies".localized(), _imageIconName: "icon_feed_movies", _imageBackgroundName: "image_event_movies", _type: "movies", _foursquareId: "Movies"))
        
        return listOfFeeds
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueCreateEvent" {
            let destinationVC = segue.destinationViewController as! CreateEventViewController
            
            let row = sender as! Int
            
            destinationVC.backgroundImage = UIImage(named: self.listOfFeeds[row].imageBackgroundName)
            destinationVC.titleText = self.listOfFeeds[row].title
            destinationVC.typeOfEvent = self.listOfFeeds[row].type
            destinationVC.foursquareId = self.listOfFeeds[row].foursquareID
        }
    }
}
