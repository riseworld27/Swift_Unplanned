//
//  ListContactsInGroupViewController.swift
//  Unplanned
//
//  Created by matata on 01.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import RealmSwift

class ListContactsInGroupViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var selectedGroup : GroupModel!

    lazy var listOfContacts : Results<RealmUserModel> = {
        let realm = try! Realm()
        return realm.objects(RealmUserModel.self).filter("groupsString CONTAINS %@", self.selectedGroup!.idGroup)
    }()

    var friendsList = [String]()
    
    override func viewDidLoad() {
        
    }
    
    
    @IBAction func clearTextPressed(sender: AnyObject) {
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupGradienNavigationBar(selectedGroup.titleGroup)
        self.createNavigationBarButtons()
        tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        
        self.getContacstsInGroup()
        self.loadFriends()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (section == 0) {
            return 1
        }

        return self.listOfContacts.count
    }


    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactsListTableViewCell") as! ContactsTableViewCell
        
        if indexPath.section == 0 {
            cell.ivUserPicture.image = UIImage(named: "icon_add_contact_big")
            cell.labelName.text = "Add member".localized()
        }
        
        else {
            
            if self.friendsList.contains(listOfContacts[indexPath.row].username) {
                cell.ivInApp.hidden = false
            } else {
                cell.ivInApp.hidden = true
            }
            
            let currentContact = self.listOfContacts[indexPath.row]
            if (currentContact.photoUrl.characters.count > 0) {
                cell.ivUserPicture.kf_setImageWithURL(NSURL(string: currentContact.photoUrl)!)
            } else {
                cell.ivUserPicture.image = UIImage(named: "icon_no_user")
            }
            cell.labelName.text = currentContact.name
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
   
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(self.listOfContacts.count) \("members".localized())"
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            self.performSegueWithIdentifier("segueEditContactsInGroup", sender: nil)
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
        
        
        var editImage:UIImage = UIImage(named: "icon_edit_contacts")!
        
        editImage = editImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
        let editButton: UIButton = UIButton(frame: CGRectMake(5, 5, 20, 20))
        editButton.setImage(editImage, forState: .Normal)
        editButton.setImage(editImage, forState: .Highlighted)
        editButton.addTarget(self, action: #selector(CreateEventViewController.submit(_:)), forControlEvents:.TouchUpInside)
        let editButtonBar = UIBarButtonItem.init(customView: editButton)
        self.navigationItem.rightBarButtonItem = editButtonBar
        
    }
    
    func close(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func submit(sender : UIButton) {
        self.performSegueWithIdentifier("segueEditContactsInGroup", sender: nil)
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFontOfSize(14.0)
        header.textLabel?.textColor = UIColor.grayColor()
        header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .Normal, title: "Delete".localized()) { action, index in
            
            let row = indexPath.row
            
            if row >= 0 {

                let user = self.listOfContacts[row]

                let query = PFQuery(className: "Group_users")
                query.whereKey("objectId", equalTo: user.objectId)

                query.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) -> Void in

                    if let objs = objects {
                        for object in objs {
                            object.deleteInBackgroundWithBlock({ (value: Bool, error : NSError?) in
                                if value == false {

                                    self.getContacstsInGroup()
                                }
                            })
                        }
                    }
                }

                let realm = try! Realm()

                try! realm.write {
                    realm.delete(user)
                }

                self.tableView.reloadData()
            }
            
        }
        delete.backgroundColor = UIColor.redColor()
        
        
        return [delete]
    }
    
    func loadFriends() {
        
        self.friendsList.removeAll()

        let user = PFUser.currentUser()

        user?.fetchInBackgroundWithBlock({ (object: PFObject?, error: NSError?) in
            if error == nil {
                self.friendsList = (user?.objectForKey("allFriends") as? [String]) ?? []
                self.tableView.reloadData()
            }
        })
        
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "segueEditContactsInGroup" {
            let destinationVC = segue.destinationViewController as! AddContactsToGroupViewController
            destinationVC.selectedGroup = self.selectedGroup
        }
    }
    
    func getContacstsInGroup() {

        let queryGetEvents = PFQuery(className: "Group_users")
        queryGetEvents.whereKey("group_id", equalTo: selectedGroup.idGroup)
        queryGetEvents.orderByAscending("full_name")
        
        queryGetEvents.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) in
            if error == nil {

                for object : PFObject in objects! {
                    
                    var imageUrl = ""
                    
                    if let photo = object.objectForKey("photo") as? PFFile {
                        imageUrl = photo.url!
                    }
                    
                    var user = RealmUserModel(_objectId: object.objectId!, _userName: object.valueForKey("username") as! String, _name: object.valueForKey("full_name") as! String, _imageUrl: imageUrl, _isAdded: object.valueForKey("in_app") as! Bool)

                    user.addGroup(self.selectedGroup.idGroup)

                    let realm = try! Realm()

                    try! realm.write {
                        realm.add(user, update: true)
                    }
                }
                
                self.tableView.reloadData()
                
            }

        }
    
    }
    
}
