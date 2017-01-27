//
//  AddContactsToGroupViewController.swift
//  Unplanned
//
//  Created by matata on 01.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import Contacts
import RealmSwift

class AddContactsToGroupViewController: BaseViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var ivClearText: UIImageView!
    
    var listOfContacts = [CNContact]()
    
    var filteredListContacts = [CNContact]()
    
    var listOfAllContacts = [CNContact]()
    
    var friendsList = [String]()
    
    var listOfContactsRemote = [RealmUserModel]()
    
    var selectedGroup : GroupModel!
    
    
    var friends = Array<UserModel>()
    override func viewDidLoad() {
        self.createNavigationBarButtons()
        self.getContactsInApp()
        self.getContactsInGroup()
        
        
        self.loadData()
        
        tfSearch.addTarget(self, action: #selector(LocationSelectViewController.textFieldDidChange(_:)), forControlEvents: UIControlEvents.EditingChanged)
        self.tfSearch.delegate = self
        
        self.tfSearch.placeholder = "Find friends".localized()
    }
 
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        self.tfSearch.resignFirstResponder()
        view.endEditing(true);
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChange(textField: UITextField) {
        if !(textField.text?.isEmpty)! {
            ivClearText.hidden = false
            
            self.filteredListContacts = listOfContacts.filter({
                
                if (CNContactFormatter().stringFromContact($0) != nil) {
                    return (CNContactFormatter().stringFromContact($0)?.lowercaseString.containsString(tfSearch.text!.lowercaseString))!
                } else { return true}
                
            })
        }
        else {
            self.filteredListContacts = self.listOfContacts
            ivClearText.hidden = true
        }
        
        self.tableView.reloadData()
    }
    
    
    @IBAction func clearTextPressed(sender: AnyObject) {
        self.tfSearch.text = ""
        ivClearText.hidden = true
        self.filteredListContacts = listOfContacts
        self.tableView.reloadData()
    }
    
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.setupGradienNavigationBar(selectedGroup.titleGroup)
        
        tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        
        self.loadFriends()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return listOfContactsRemote.count
            
        case 1:
            return self.filteredListContacts.count
        default : return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ContactsTableViewCell") as! ContactsTableViewCell
        let row = indexPath.row
        switch indexPath.section {
        case 0:
            
            if self.friendsList.contains(listOfContactsRemote[row].username) {
                cell.ivInApp.hidden = false
            } else {
                cell.ivInApp.hidden = true
            }
            
            
        
            cell.labelName.text = listOfContactsRemote[row].name
            
            cell.ivAdded.image = UIImage(named: "icon_group_added_yes")
            cell.labelPhoneNumber.text = listOfContactsRemote[row].username
            
            if listOfContactsRemote[row].photoUrl.characters.count > 0 {
                cell.ivUserPicture.kf_setImageWithURL(NSURL(string: listOfContactsRemote[row].photoUrl)!)
            } else {
                cell.ivUserPicture.image = UIImage(named: "icon_no_user")
            }
            break
        default:
                cell.ivAdded.image = UIImage(named: "icon_group_added_no")
                let contact = self.filteredListContacts[row]
                
                
               
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    if contact.imageDataAvailable {
                        if let data = contact.imageData {
                            cell.ivUserPicture.image = UIImage(data: data)
                        } else {
                            cell.ivUserPicture.image = UIImage(named: "icon_no_user")
                        }
                    }else {
                        cell.ivUserPicture.image = UIImage(named: "icon_no_user")
                    }
                    
                    cell.labelName.text = CNContactFormatter().stringFromContact(contact)
                    
                    if contact.phoneNumbers.count > 0 {
                        let number = contact.phoneNumbers[0].value as! CNPhoneNumber
                        
                        
                        var phoneStr = number.valueForKey("digits") as! String
                        
                        if !phoneStr.containsString("+") {
                            phoneStr = "+52\(phoneStr)"
                        }

                        
                        
                        cell.labelPhoneNumber.text = phoneStr
                        
                        
                        
                        if self.friendsList.contains(phoneStr) {
                            cell.ivInApp.hidden = false
                        } else {
                            cell.ivInApp.hidden = true
                        }
                    }
                    
                    
                })
            
            
            break
        }
        
        return cell
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        switch section {
        case 0:
            let header = view as! UITableViewHeaderFooterView
            
            header.textLabel?.font = UIFont.systemFontOfSize(14.0)
            header.textLabel?.textColor = UIColor(rgba: "#5E6066")
            header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
            
        default:
            let header = view as! UITableViewHeaderFooterView
            
            header.textLabel?.textColor = UIColor.whiteColor()
            header.textLabel?.font = UIFont.systemFontOfSize(12.0)
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors =  [UIColor(rgba: "#00C7B6"),UIColor(rgba: "#00BAC5")].map{$0.CGColor}
            
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            gradientLayer.frame = header.bounds
            let backgroundView = UIView(frame: header.bounds)
            backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
            
            header.backgroundView = backgroundView
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = UITableViewHeaderFooterView(frame: CGRectMake(0,0,self.view.size().width, 30))
            
            //header.textLabel?.font = UIFont.systemFontOfSize(14.0)
            header.textLabel?.textColor = UIColor(rgba: "#5E6066")
            header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
            
            return header
            
        default:
            let header = UITableViewHeaderFooterView(frame: CGRectMake(0,0,self.view.size().width, 30))
            
            header.textLabel?.textColor = UIColor.whiteColor()
            //header.textLabel?.font = UIFont.systemFontOfSize(12.0)
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors =  [UIColor(rgba: "#00C7B6"),UIColor(rgba: "#00BAC5")].map{$0.CGColor}
            
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            gradientLayer.frame = header.bounds
            let backgroundView = UIView(frame: header.bounds)
            backgroundView.layer.insertSublayer(gradientLayer, atIndex: 0)
            
            header.backgroundView = backgroundView
            
            
            return header
        }

    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "\(self.listOfContactsRemote.count) \("members".localized())"
        default:
            return "All contacts".localized()
        }

    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.view.endEditing(true)
        if indexPath.section == 0 {
            deleteContact(self.listOfContactsRemote[indexPath.row])
        return
        }
        
        
        let contact = self.filteredListContacts[indexPath.row]
        
        var image : UIImage?
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if contact.imageDataAvailable {
                if let data = contact.imageData {
                    image = UIImage(data: data)!
                }
            }
            
            var phoneStr = ""
            if contact.phoneNumbers.count > 0 {
                let number = contact.phoneNumbers[0].value as! CNPhoneNumber
                phoneStr = number.valueForKey("digits") as! String
                
                if !phoneStr.containsString("+") {
                    phoneStr = "+52\(phoneStr)"
                }
            }
            
            
            self.addContact(CNContactFormatter().stringFromContact(contact)!, username: phoneStr, image: image)
            
        })
        
        
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
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventViewController.submit(_:)))
        
    }
    
    func close(sender: UIButton) {
        for vc : UIViewController in (self.navigationController?.viewControllers)! {
            if vc.isKindOfClass(ListGroupsViewController) || vc.isKindOfClass(CreateEventViewController) ||  vc.isKindOfClass(ListContactsInGroupViewController){
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    
    
    func submit(sender : UIButton) {
        //self.navigationController?.popToRootViewControllerAnimated(true)
        
        
        for vc : UIViewController in (self.navigationController?.viewControllers)! {
            if vc.isKindOfClass(ListGroupsViewController) || vc.isKindOfClass(CreateEventViewController){
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    
    func loadData()
    {
        guard let friends = UserModel.currentUser()?.allFriends as? [PFObject] else { return }
        let castedFriends = friends.map { UserModel(withoutDataWithClassName: UserModel.parseClassName(), objectId: $0.objectId!) }
        
        UserModel.fetchAllInBackground(castedFriends, block: { (fetchedFriends, error) in
            guard let friends = fetchedFriends as? [UserModel] else { UIMsg("Failed to fetch friends \(error?.localizedDescription ?? "")"); return }
            self.friends = friends
            self.tableView.reloadData()
        })
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
    
    func getContactsInApp() {
        let contactStore = CNContactStore()
        var results: [CNContact] = []
        do {
            
            let fetch = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeysForStyle(.FullName),CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactPostalAddressesKey, CNContactImageDataKey, CNContactImageDataAvailableKey])
            fetch.sortOrder = .GivenName
            
            try contactStore.enumerateContactsWithFetchRequest(fetch) {
                (contact, cursor) -> Void in
                results.append(contact)
            }
        }
        catch{
            print("Handle the error please")
        }
        
        self.listOfContacts = results
        self.filteredListContacts = results
        self.listOfAllContacts = results
        self.tableView.reloadData()
    }
    
    func addContact(fullName: String , username : String, image : UIImage?) {
        let objectUser = PFObject(className: "Group_users")
        
        objectUser.setValue(self.selectedGroup.idGroup, forKey: "group_id")
        objectUser.setValue(fullName, forKey: "full_name")
        objectUser.setValue(username, forKey: "username")
        if let imageFile = image {
            let imageData = UIImagePNGRepresentation(imageFile)
            let imageFile:PFFile = PFFile(data: imageData!)!
            objectUser.setObject(imageFile, forKey: "photo")
        }
        objectUser.setValue(false, forKey: "in_app")
        objectUser.setObject(PFUser.currentUser()!, forKey: "user")

        let realm = try! Realm()

        var user = realm.objects(RealmUserModel.self).filter("username = %@", username).first

        if let u = user {

            try! realm.write {
                u.addGroup(self.selectedGroup.idGroup)
            }
        }

        objectUser.saveInBackgroundWithBlock { (done: Bool, error: NSError?) -> Void in
            if error == nil {
                self.getContactsInGroup()
            }
        }

    }
    
    func deleteContact(contact : RealmUserModel) {
        let queryGetEvents = PFQuery(className: "Group_users")
        //queryGetEvents.whereKey("group_id", equalTo: selectedGroup.idGroup)
        queryGetEvents.orderByDescending("createdAt")

        let realm = try! Realm()

        var user = realm.objects(RealmUserModel.self).filter("username = %@", contact.username).first

        if let u = user {

            try! realm.write {
                u.removeGroup(self.selectedGroup.idGroup)
            }
        }

        queryGetEvents.getObjectInBackgroundWithId(contact.objectId) { (object : PFObject?, error : NSError?) in
            object?.deleteInBackgroundWithBlock({ (done: Bool, error: NSError?) in
                self.getContactsInGroup()
            })
        }

    }
    
    
    func getContactsInGroup() {

        let queryGetEvents = PFQuery(className: "Group_users")
        queryGetEvents.whereKey("group_id", equalTo: selectedGroup.idGroup)
        queryGetEvents.orderByAscending("full_name")
        
        queryGetEvents.findObjectsInBackgroundWithBlock { (objects : [PFObject]?, error: NSError?) in
            if error == nil {

                self.listOfContactsRemote.removeAll()

                self.listOfContacts = self.listOfAllContacts
                self.filteredListContacts = self.listOfAllContacts
                
                for object : PFObject in objects! {
                    
                    var imageUrl = ""
                    
                    if let photo = object.objectForKey("photo") as? PFFile {
                        imageUrl = photo.url!
                    }
                    
                    
                    
                    for item : CNContact in self.listOfAllContacts {
                        if object.valueForKey("full_name") as? String == CNContactFormatter().stringFromContact(item) {
                            self.listOfContacts.removeObject(item)
                            self.filteredListContacts.removeObject(item)
                        }
                    }

                    let user = RealmUserModel(_objectId: object.objectId!, _userName: object.valueForKey("username") as! String, _name: object.valueForKey("full_name") as! String, _imageUrl: imageUrl, _isAdded: object.valueForKey("in_app") as! Bool)

                    self.listOfContactsRemote.append(user)
                }
                self.textFieldDidChange(self.tfSearch)
                self.tableView.reloadData()
                
            }
        }
        
    }

}
