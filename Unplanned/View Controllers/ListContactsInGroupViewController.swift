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
    
    
    @IBAction func clearTextPressed(_ sender: AnyObject) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.setupGradienNavigationBar(selectedGroup.titleGroup)
        self.createNavigationBarButtons()
        tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        
        self.getContacstsInGroup()
        self.loadFriends()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if (section == 0) {
            return 1
        }

        return self.listOfContacts.count
    }


    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsListTableViewCell") as! ContactsTableViewCell
        
        if indexPath.section == 0 {
            cell.ivUserPicture.image = UIImage(named: "icon_add_contact_big")
            cell.labelName.text = "Add member".localized()
        }
        
        else {
            
            if self.friendsList.contains(listOfContacts[indexPath.row].username) {
                cell.ivInApp.isHidden = false
            } else {
                cell.ivInApp.isHidden = true
            }
            
            let currentContact = self.listOfContacts[indexPath.row]
            if (currentContact.photoUrl.characters.count > 0) {
                cell.ivUserPicture.kf_setImageWithURL(URL(string: currentContact.photoUrl)!)
            } else {
                cell.ivUserPicture.image = UIImage(named: "icon_no_user")
            }
            cell.labelName.text = currentContact.name
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
   
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "\(self.listOfContacts.count) \("members".localized())"
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "segueEditContactsInGroup", sender: nil)
        }
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
        
        
        var editImage:UIImage = UIImage(named: "icon_edit_contacts")!
        
        editImage = editImage.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let editButton: UIButton = UIButton(frame: CGRect(x: 5, y: 5, width: 20, height: 20))
        editButton.setImage(editImage, for: UIControlState())
        editButton.setImage(editImage, for: .highlighted)
        editButton.addTarget(self, action: #selector(CreateEventViewController.submit(_:)), for:.touchUpInside)
        let editButtonBar = UIBarButtonItem.init(customView: editButton)
        self.navigationItem.rightBarButtonItem = editButtonBar
        
    }
    
    func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func submit(_ sender : UIButton) {
        self.performSegue(withIdentifier: "segueEditContactsInGroup", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
        header.textLabel?.textColor = UIColor.gray
        header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete".localized()) { action, index in
            
            let row = indexPath.row
            
            if row >= 0 {

                let user = self.listOfContacts[row]

                let query = PFQuery(className: "Group_users")
                query.whereKey("objectId", equalTo: user.objectId)

                query.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) -> Void in

                    if let objs = objects {
                        for object in objs {
                            object.deleteInBackground(block: { (value: Bool, error : NSError?) in
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
        delete.backgroundColor = UIColor.red
        
        
        return [delete]
    }
    
    func loadFriends() {
        
        self.friendsList.removeAll()

        let user = PFUser.current()

        user?.fetchInBackground(block: { (object: PFObject?, error: NSError?) in
            if error == nil {
                self.friendsList = (user?.object(forKey: "allFriends") as? [String]) ?? []
                self.tableView.reloadData()
            }
        })
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueEditContactsInGroup" {
            let destinationVC = segue.destination as! AddContactsToGroupViewController
            destinationVC.selectedGroup = self.selectedGroup
        }
    }
    
    func getContacstsInGroup() {

        let queryGetEvents = PFQuery(className: "Group_users")
        queryGetEvents.whereKey("group_id", equalTo: selectedGroup.idGroup)
        queryGetEvents.order(byAscending: "full_name")
        
        queryGetEvents.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) in
            if error == nil {

                for object : PFObject in objects! {
                    
                    var imageUrl = ""
                    
                    if let photo = object.object(forKey: "photo") as? PFFile {
                        imageUrl = photo.url!
                    }
                    
                    var user = RealmUserModel(_objectId: object.objectId!, _userName: object.value(forKey: "username") as! String, _name: object.value(forKey: "full_name") as! String, _imageUrl: imageUrl, _isAdded: object.value(forKey: "in_app") as! Bool)

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
