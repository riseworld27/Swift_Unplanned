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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DetailsPeopleCell") as! DetailsPeopleCell
        
        cell.labelUserName.text = listContacts[indexPath.row].name
        cell.ivUserImage.kf_setImageWithURL(URL(string: listContacts[indexPath.row].photoUrl ?? "")!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "  \(self.listContacts.count) \("Confirmed".localized())"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
            let header = view as! UITableViewHeaderFooterView
            
            header.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            header.textLabel?.textColor = UIColor(rgba: "#5E6066")
            header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func getMembersInfo() {

        let queryGetUsers = PFQuery(className: "_User")
        queryGetUsers.whereKey("username", containedIn: listMembers as! [String])
        queryGetUsers.order(byDescending: "createdAt")
        queryGetUsers.includeKey("user")
        
        queryGetUsers.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) in
            if error == nil {
                for object : PFObject in objects! {
                    
                    var imageUrl = ""
                    
                    if let photo = object.object(forKey: "photo") as? PFFile {
                        imageUrl = photo.url!
                    }
                    
                    let user = RealmUserModel(_objectId: object.objectId!, _userName: object.value(forKey: "username") as! String, _name: "\(object.value(forKey: "firstName") as! String) \(object.value(forKey: "lastName") as! String)", _imageUrl: imageUrl, _isAdded: true)

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
}
