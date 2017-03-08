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
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupGradienNavigationBar("My Groups".localized())
        self.createNavigationBarButtons()
        
        self.getGroups()
        tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if section == 0 {
            return 1
        }

        return listGroups.count
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListTableViewCell") as! GroupListTableViewCell
        
        
        
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if indexPath.section == 0 {
            self.performSegue(withIdentifier: "segueAddGroup", sender: nil)
        } else {
            self.performSegue(withIdentifier: "segueShowContactsInGroup", sender: indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete".localized()) { action, index in
            print("more button tapped")
            
            if indexPath.section == 1 {

                let group = self.listGroups[indexPath.row]

                let query = PFQuery(className: "Group")
                query.whereKey("objectId", equalTo: group.idGroup)

                query.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) -> Void in

                    if let objs = objects {
                        for object in objs {
                            object.deleteInBackground(block: { (value: Bool, error : NSError?) in
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
        delete.backgroundColor = UIColor.red
        
        
        return [delete]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "segueShowContactsInGroup" {
            let destinationVC = segue.destination as! ListContactsInGroupViewController
            destinationVC.selectedGroup = self.listGroups[sender as! Int]
        }
    }
}
