//
//  EventGroupViewController.swift
//  Unplanned
//
//  Created by matata on 29.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import RealmSwift

class EventGroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var viewHeaderTable: UIView!

    lazy var listGroups : Results<GroupModel> = {
        let realm = try! Realm()
        return realm.objects(GroupModel.self)
    }()
    
    
    var selectedGroups = [GroupModel]()
    var inviteAll = false
    
    @IBOutlet weak var buttonDone: UIButton!
    @IBOutlet weak var labelGroup: UILabel!
    
    @IBOutlet weak var labelSelectedGroup: UILabel!
    @IBOutlet weak var ivSelectedGroup: UIImageView!
    @IBOutlet weak var viewSelectedGroup: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var iconSelectGroup: UIImageView!
    @IBOutlet weak var btnSelectGroup: UIButton!
    
    override func viewDidLoad() {
        btnSelectGroup.layer.cornerRadius = 20
        btnSelectGroup.layer.borderWidth = 2
        btnSelectGroup.layer.borderColor = UIColor(rgba: "#00BEE0").CGColor
        
        viewSelectedGroup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventGroupViewController.btnSelectGroupPressed(_:))))
        self.btnSelectGroup.setTitle("Invite friends".localized(), forState: .Normal)
        
        self.labelGroup.text = "Groups".localized()
        self.buttonDone.setTitle("Done".localized(), forState: .Normal)

        self.viewSelectedGroup.hidden = true
        self.tableView.hidden = false
        self.viewHeaderTable.hidden = false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.getGroups()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }

        return listGroups.count
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }


    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("groupTableViewCell") as! GroupTableViewCell

        if (indexPath.section == 0) {

            if (indexPath.row == 0) {
                cell.ivActivaBackground.hidden = true
                cell.labelTitle.text = "Create group".localized()
                cell.ivIcon.image = UIImage(named: "icon_create_group")
            } else {
                cell.ivActivaBackground.hidden = false
                cell.labelTitle.text = "Invite all".localized()
                cell.ivIcon.image = UIImage(named: "icon_invite_all")
            }
        } else {
            cell.ivActivaBackground.hidden = false
            cell.labelTitle.text = listGroups[indexPath.row].titleGroup
            cell.ivIcon.image = UIImage(named: listGroups[indexPath.row].imageUrlGroup)
        }
        
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        if (indexPath.section == 0) {
            if indexPath.row == 0 {
                self.performSegueWithIdentifier("segueCreateGroupFromEvent", sender: nil)
                return
            }
            if indexPath.row == 1 {
                self.inviteAll = true
            }
        }

        self.inviteAll = false

        tableView.reloadData()
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! GroupTableViewCell
        
        if (cell.ivIsActive.hidden) {
            cell.ivIsActive.hidden = false
            self.selectedGroups.append(self.listGroups[indexPath.row])
        } else {
            cell.ivIsActive.hidden = true
            self.selectedGroups.removeObject(self.listGroups[indexPath.row])
        }
        
        self.labelSelectedGroup.text =  cell.labelTitle.text
        self.ivSelectedGroup.image = cell.ivIcon.image
    }
    
    
    
    @IBAction func submitButtonPressed(sender: AnyObject) {
        
//        if (self.labelSelectedGroup.text == "") {
//            return
//        }
//        self.tableView.hidden = true
//        self.viewHeaderTable.hidden = true
//        self.viewSelectedGroup.hidden = false
//        self.iconSelectGroup.hidden = true
//        self.btnSelectGroup.hidden = true
    }
    
    @IBAction func btnSelectGroupPressed(sender: AnyObject) {
        self.viewSelectedGroup.hidden = true
        self.tableView.hidden = false
        self.viewHeaderTable.hidden = false
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

}

