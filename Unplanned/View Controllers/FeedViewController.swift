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
        
        menuImage = menuImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let menuButton: UIButton = UIButton(frame: CGRect(x: 20, y: 20, width: 25, height: 25))
        menuButton.setImage(menuImage, for: UIControlState())
        menuButton.setImage(menuImage, for: .highlighted)
        menuButton.addTarget(self, action: #selector(FeedViewController.menu(_:)), for:.touchUpInside)

        let badge: DBBadgeLabel = DBBadgeLabel(cornerRadius: 9, textColor: UIColor.white, backgroundColor: UIColor(hex6:0x672890))
        badge.text = "\(UIApplication.shared.applicationIconBadgeNumber)"
        badge.font = UIFont.systemFont(ofSize: 9)
        badge.textAlignment = NSTextAlignment.center
        badge.frame = CGRect(x: 25, y: -3, width: 18, height: 18)
        badge.isHidden = UIApplication.shared.applicationIconBadgeNumber == 0
        menuButton.addSubview(badge)

        let menuButtonBar = UIBarButtonItem.init(customView: menuButton)
        self.navigationItem.leftBarButtonItem = menuButtonBar
        
        self.tableView.contentInset = UIEdgeInsets(top: 100,left: 0,bottom: 0,right: 0)

        badgeObserver = NotificationObserver(NotificationsHelper.badgeNotification) {

            (value, sender) in

            badge.isHidden = UIApplication.shared.applicationIconBadgeNumber == 0
            badge.text = "\(UIApplication.shared.applicationIconBadgeNumber)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setTransparentNavigationBar("What do you want to do?".localized())
    }
    
    func menu(_ sender: UIButton){
        let vc = SideMenuManager.menuLeftNavigationController
        self.present(vc!, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfFeeds.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedTableViewCell", for: indexPath) as! FeedTableViewCell
        
        let row = indexPath.row
        
        
        cell.ivImageFeed.image = UIImage(named: self.listOfFeeds[row].imageIconName)
        cell.labelTitle.text = self.listOfFeeds[row].title
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "segueCreateEvent", sender: indexPath.row)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueCreateEvent" {
            let destinationVC = segue.destination as! CreateEventViewController
            
            let row = sender as! Int
            
            destinationVC.backgroundImage = UIImage(named: self.listOfFeeds[row].imageBackgroundName)
            destinationVC.titleText = self.listOfFeeds[row].title
            destinationVC.typeOfEvent = self.listOfFeeds[row].type
            destinationVC.foursquareId = self.listOfFeeds[row].foursquareID
        }
    }
}
