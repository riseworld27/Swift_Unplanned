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
        btnSelectGroup.layer.borderColor = UIColor(rgba: "#00BEE0").cgColor
        
        viewSelectedGroup.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(EventGroupViewController.btnSelectGroupPressed(_:))))
        self.btnSelectGroup.setTitle("Invite friends".localized(), for: UIControlState())
        
        self.labelGroup.text = "Groups".localized()
        self.buttonDone.setTitle("Done".localized(), for: UIControlState())

        self.viewSelectedGroup.isHidden = true
        self.tableView.isHidden = false
        self.viewHeaderTable.isHidden = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getGroups()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        }

        return listGroups.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "groupTableViewCell") as! GroupTableViewCell

        if (indexPath.section == 0) {

            if (indexPath.row == 0) {
                cell.ivActivaBackground.isHidden = true
                cell.labelTitle.text = "Create group".localized()
                cell.ivIcon.image = UIImage(named: "icon_create_group")
            } else {
                cell.ivActivaBackground.isHidden = false
                cell.labelTitle.text = "Invite all".localized()
                cell.ivIcon.image = UIImage(named: "icon_invite_all")
            }
        } else {
            cell.ivActivaBackground.isHidden = false
            cell.labelTitle.text = listGroups[indexPath.row].titleGroup
            cell.ivIcon.image = UIImage(named: listGroups[indexPath.row].imageUrlGroup)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath.section == 0) {
            if indexPath.row == 0 {
                self.performSegue(withIdentifier: "segueCreateGroupFromEvent", sender: nil)
                return
            }
            if indexPath.row == 1 {
                self.inviteAll = true
            }
        }

        self.inviteAll = false

        tableView.reloadData()
        let cell = tableView.cellForRow(at: indexPath) as! GroupTableViewCell
        
        if (cell.ivIsActive.isHidden) {
            cell.ivIsActive.isHidden = false
            self.selectedGroups.append(self.listGroups[indexPath.row])
        } else {
            cell.ivIsActive.isHidden = true
            self.selectedGroups.removeObject(self.listGroups[indexPath.row])
        }
        
        self.labelSelectedGroup.text =  cell.labelTitle.text
        self.ivSelectedGroup.image = cell.ivIcon.image
    }
    
    
    
    @IBAction func submitButtonPressed(_ sender: AnyObject) {
        
//        if (self.labelSelectedGroup.text == "") {
//            return
//        }
//        self.tableView.hidden = true
//        self.viewHeaderTable.hidden = true
//        self.viewSelectedGroup.hidden = false
//        self.iconSelectGroup.hidden = true
//        self.btnSelectGroup.hidden = true
    }
    
    @IBAction func btnSelectGroupPressed(_ sender: AnyObject) {
        self.viewSelectedGroup.isHidden = true
        self.tableView.isHidden = false
        self.viewHeaderTable.isHidden = false
    }
    
    func getGroups() {

        let queryGetEvents = PFQuery(className: "Group")
        queryGetEvents.whereKey("user", equalTo: PFUser.current()!)
        queryGetEvents.order(byDescending: "createdAt")
        queryGetEvents.includeKey("user")
        
        queryGetEvents.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) in
            if error == nil {

                let realm = try! Realm()

                for object : PFObject in objects! {

                    let group = GroupModel(_idGroup: object.objectId!, _titleGroup: object.value(forKey: "title") as! String, _typeGroup: object.value(forKey: "type") as! String, _imageUrlGroup: "group_\(object.value(forKey: "type") as! String)")

                    try! realm.write {
                        realm.add(group, update: true)
                    }
                }

                self.tableView.reloadData()
            }
            
        }
    }

}

