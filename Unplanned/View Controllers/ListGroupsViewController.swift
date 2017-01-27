//
//  ListGroupsViewController.swift
//  Unplanned
//
//  Created by matata on 31.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import Contacts
import RealmSwift

class ListGroupsViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    var contactStore = CNContactStore()

    lazy var listGroups : Results<GroupModel> = {
        let realm = try! Realm()
        return realm.objects(GroupModel.self)
    }()

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        
    }
    
    override func viewWillAppear(animated: Bool) {
        self.setupGradienNavigationBar("My Groups".localized())
        self.createNavigationBarButtons()
        
        self.getGroups()
        tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return 1
        }

        return listGroups.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupListTableViewCell") as! GroupListTableViewCell
        
        
        
        if indexPath.section == 0 {
            cell.labelTitle.text = "Create group".localized()
            cell.ivPicture.image = UIImage(named: "icon_create_group_big")
        }
        else {
            
            let currentItem = listGroups[indexPath.row]
            
            cell.ivPicture.image = UIImage(named: currentItem.imageUrlGroup)
            cell.labelTitle.text = currentItem.titleGroup
        }
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        
        if indexPath.section == 0 {
            self.performSegueWithIdentifier("segueAddGroup", sender: nil)
        } else {
            self.performSegueWithIdentifier("segueShowContactsInGroup", sender: indexPath.row)
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete".localized()) { action, index in
            print("more button tapped")
            
            if indexPath.section == 1 {

                let group = self.listGroups[indexPath.row]

                let query = PFQuery(className: "Group")
                query.whereKey("objectId", equalTo: group.idGroup)

                query.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) -> Void in

                    if let objs = objects {
                        for object in objs {
                            object.deleteInBackgroundWithBlock({ (value: Bool, error : NSError?) in
                                if value == false {

                                    self.getGroups()
                                }
                            })
                        }
                    }
                }

                let realm = try! Realm()

                try! realm.write {
                    realm.delete(group)
                }

                self.tableView.reloadData()
            }
            
        }
        delete.backgroundColor = UIColor.redColor()
        
        
        return [delete]
    }
    
    func getGroups() {

        let queryGetEvents = PFQuery(className: "Group")
        queryGetEvents.whereKey("user", equalTo: PFUser.currentUser()!)
        queryGetEvents.orderByDescending("createdAt")
        queryGetEvents.includeKey("user")
        
        queryGetEvents.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) in
            if error == nil {

                let realm = try! Realm()

                for object : PFObject in objects! {

                    let group = GroupModel(_idGroup: object.objectId!, _titleGroup: object.valueForKey("title") as! String, _typeGroup: object.valueForKey("type") as! String, _imageUrlGroup: "group_\(object.valueForKey("type") as! String)")

                    try! realm.write {
                        realm.add(group, update: true)
                    }
                }
                
                self.tableView.reloadData()
                
            }

        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueShowContactsInGroup" {
            let destinationVC = segue.destinationViewController as! ListContactsInGroupViewController
            destinationVC.selectedGroup = self.listGroups[sender as! Int]
        }
    }
}
