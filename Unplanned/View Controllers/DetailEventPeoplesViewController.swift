//
//  DetailEventPeoplesViewController.swift
//  Unplanned
//
//  Created by matata on 31.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import RealmSwift

class DetailEventPeoplesViewController: BaseViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!

    lazy var listContacts : Results<RealmUserModel> = {
        let realm = try! Realm()
        return realm.objects(RealmUserModel.self).filter("username IN %@", self.listMembers!)
    }()

    var listMembers : NSArray!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.getMembersInfo()
        self.createNavigationBarButtons()
        self.setupGradienNavigationBar("Confirmed".localized())
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listContacts.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DetailsPeopleCell") as! DetailsPeopleCell
        
        cell.labelUserName.text = listContacts[indexPath.row].name
        cell.ivUserImage.kf_setImageWithURL(NSURL(string: listContacts[indexPath.row].photoUrl ?? "")!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "  \(self.listContacts.count) \("Confirmed".localized())"
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
            let header = view as! UITableViewHeaderFooterView
            
            header.textLabel?.font = UIFont.systemFontOfSize(14.0)
            header.textLabel?.textColor = UIColor(rgba: "#5E6066")
            header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func getMembersInfo() {

        let queryGetUsers = PFQuery(className: "_User")
        queryGetUsers.whereKey("username", containedIn: listMembers as! [String])
        queryGetUsers.orderByDescending("createdAt")
        queryGetUsers.includeKey("user")
        
        queryGetUsers.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) in
            if error == nil {
                for object : PFObject in objects! {
                    
                    var imageUrl = ""
                    
                    if let photo = object.objectForKey("photo") as? PFFile {
                        imageUrl = photo.url!
                    }
                    
                    let user = RealmUserModel(_objectId: object.objectId!, _userName: object.valueForKey("username") as! String, _name: "\(object.valueForKey("firstName") as! String) \(object.valueForKey("lastName") as! String)", _imageUrl: imageUrl, _isAdded: true)

                    let realm = try! Realm()

                    try! realm.write {
                        realm.add(user, update: true)
                    }
                }
                self.tableView.reloadData()
            }
        }
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
}
