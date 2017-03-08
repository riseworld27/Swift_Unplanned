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
        
        tfSearch.addTarget(self, action: #selector(LocationSelectViewController.textFieldDidChange(_:)), for: UIControlEvents.editingChanged)
        self.tfSearch.delegate = self
        
        self.tfSearch.placeholder = "Find friends".localized()
    }
 
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        self.tfSearch.resignFirstResponder()
        view.endEditing(true);
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidChange(_ textField: UITextField) {
        if !(textField.text?.isEmpty)! {
            ivClearText.isHidden = false
            
            self.filteredListContacts = listOfContacts.filter({
                
                if (CNContactFormatter().string(from: $0) != nil) {
                    return (CNContactFormatter().string(from: $0)?.lowercased().contains(tfSearch.text!.lowercased()))!
                } else { return true}
                
            })
        }
        else {
            self.filteredListContacts = self.listOfContacts
            ivClearText.isHidden = true
        }
        
        self.tableView.reloadData()
    }
    
    
    @IBAction func clearTextPressed(_ sender: AnyObject) {
        self.tfSearch.text = ""
        ivClearText.isHidden = true
        self.filteredListContacts = listOfContacts
        self.tableView.reloadData()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupGradienNavigationBar(selectedGroup.titleGroup)
        
        tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
        
        self.loadFriends()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return listOfContactsRemote.count
            
        case 1:
            return self.filteredListContacts.count
        default : return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactsTableViewCell") as! ContactsTableViewCell
        let row = indexPath.row
        switch indexPath.section {
        case 0:
            
            if self.friendsList.contains(listOfContactsRemote[row].username) {
                cell.ivInApp.isHidden = false
            } else {
                cell.ivInApp.isHidden = true
            }
            
            
        
            cell.labelName.text = listOfContactsRemote[row].name
            
            cell.ivAdded.image = UIImage(named: "icon_group_added_yes")
            cell.labelPhoneNumber.text = listOfContactsRemote[row].username
            
            if listOfContactsRemote[row].photoUrl.characters.count > 0 {
                cell.ivUserPicture.kf_setImageWithURL(URL(string: listOfContactsRemote[row].photoUrl)!)
            } else {
                cell.ivUserPicture.image = UIImage(named: "icon_no_user")
            }
            break
        default:
                cell.ivAdded.image = UIImage(named: "icon_group_added_no")
                let contact = self.filteredListContacts[row]
                
                
               
                
                DispatchQueue.main.async(execute: { () -> Void in
                    if contact.imageDataAvailable {
                        if let data = contact.imageData {
                            cell.ivUserPicture.image = UIImage(data: data)
                        } else {
                            cell.ivUserPicture.image = UIImage(named: "icon_no_user")
                        }
                    }else {
                        cell.ivUserPicture.image = UIImage(named: "icon_no_user")
                    }
                    
                    cell.labelName.text = CNContactFormatter().string(from: contact)
                    
                    if contact.phoneNumbers.count > 0 {
                        let number = contact.phoneNumbers[0].value 
                        
                        
                        var phoneStr = number.value(forKey: "digits") as! String
                        
                        if !phoneStr.contains("+") {
                            phoneStr = "+52\(phoneStr)"
                        }

                        
                        
                        cell.labelPhoneNumber.text = phoneStr
                        
                        
                        
                        if self.friendsList.contains(phoneStr) {
                            cell.ivInApp.isHidden = false
                        } else {
                            cell.ivInApp.isHidden = true
                        }
                    }
                    
                    
                })
            
            
            break
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int)
    {
        switch section {
        case 0:
            let header = view as! UITableViewHeaderFooterView
            
            header.textLabel?.font = UIFont.systemFont(ofSize: 14.0)
            header.textLabel?.textColor = UIColor(rgba: "#5E6066")
            header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
            
        default:
            let header = view as! UITableViewHeaderFooterView
            
            header.textLabel?.textColor = UIColor.white
            header.textLabel?.font = UIFont.systemFont(ofSize: 12.0)
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors =  [UIColor(rgba: "#00C7B6"),UIColor(rgba: "#00BAC5")].map{$0.cgColor}
            
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            gradientLayer.frame = header.bounds
            let backgroundView = UIView(frame: header.bounds)
            backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            
            header.backgroundView = backgroundView
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0:
            let header = UITableViewHeaderFooterView(frame: CGRect(x: 0,y: 0,width: self.view.size().width, height: 30))
            
            //header.textLabel?.font = UIFont.systemFontOfSize(14.0)
            header.textLabel?.textColor = UIColor(rgba: "#5E6066")
            header.backgroundView?.backgroundColor = UIColor(rgba: "#F7F7F7")
            
            return header
            
        default:
            let header = UITableViewHeaderFooterView(frame: CGRect(x: 0,y: 0,width: self.view.size().width, height: 30))
            
            header.textLabel?.textColor = UIColor.white
            //header.textLabel?.font = UIFont.systemFontOfSize(12.0)
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors =  [UIColor(rgba: "#00C7B6"),UIColor(rgba: "#00BAC5")].map{$0.cgColor}
            
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
            
            gradientLayer.frame = header.bounds
            let backgroundView = UIView(frame: header.bounds)
            backgroundView.layer.insertSublayer(gradientLayer, at: 0)
            
            header.backgroundView = backgroundView
            
            
            return header
        }

    }
    
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "\(self.listOfContactsRemote.count) \("members".localized())"
        default:
            return "All contacts".localized()
        }

    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.view.endEditing(true)
        if indexPath.section == 0 {
            deleteContact(self.listOfContactsRemote[indexPath.row])
        return
        }
        
        
        let contact = self.filteredListContacts[indexPath.row]
        
        var image : UIImage?
        
        DispatchQueue.main.async(execute: { () -> Void in
            if contact.imageDataAvailable {
                if let data = contact.imageData {
                    image = UIImage(data: data)!
                }
            }
            
            var phoneStr = ""
            if contact.phoneNumbers.count > 0 {
                let number = contact.phoneNumbers[0].value 
                phoneStr = number.value(forKey: "digits") as! String
                
                if !phoneStr.contains("+") {
                    phoneStr = "+52\(phoneStr)"
                }
            }
            
            
            self.addContact(CNContactFormatter().string(from: contact)!, username: phoneStr, image: image)
            
        })
        
        
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
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done".localized(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateEventViewController.submit(_:)))
        
    }
    
    func close(_ sender: UIButton) {
        for vc : UIViewController in (self.navigationController?.viewControllers)! {
            if vc.isKind(of: ListGroupsViewController.self) || vc.isKind(of: CreateEventViewController.self) ||  vc.isKind(of: ListContactsInGroupViewController.self){
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    
    
    func submit(_ sender : UIButton) {
        //self.navigationController?.popToRootViewControllerAnimated(true)
        
        
        for vc : UIViewController in (self.navigationController?.viewControllers)! {
            if vc.isKind(of: ListGroupsViewController.self) || vc.isKind(of: CreateEventViewController.self){
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    
    
    func loadData()
    {
        guard let friends = UserModel.current()?.allFriends as? [PFObject] else { return }
        let castedFriends = friends.map { UserModel(withoutDataWithClassName: UserModel.parseClassName(), objectId: $0.objectId!) }
        
        UserModel.fetchAll(inBackground: castedFriends, block: { (fetchedFriends, error) in
            guard let friends = fetchedFriends as? [UserModel] else { UIMsg("Failed to fetch friends \(error?.localizedDescription ?? "")"); return }
            self.friends = friends
            self.tableView.reloadData()
        })
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
    
    func getContactsInApp() {
        let contactStore = CNContactStore()
        var results: [CNContact] = []
        do {
            
            let fetch = CNContactFetchRequest(keysToFetch: [CNContactFormatter.descriptorForRequiredKeys(for: .fullName),CNContactPhoneNumbersKey as CNKeyDescriptor, CNContactEmailAddressesKey as CNKeyDescriptor, CNContactPostalAddressesKey as CNKeyDescriptor, CNContactImageDataKey as CNKeyDescriptor, CNContactImageDataAvailableKey as CNKeyDescriptor])
            fetch.sortOrder = .givenName
            
            try contactStore.enumerateContacts(with: fetch) {
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
    
    func addContact(_ fullName: String , username : String, image : UIImage?) {
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
        objectUser.setObject(PFUser.current()!, forKey: "user")

        let realm = try! Realm()

        var user = realm.objects(RealmUserModel.self).filter("username = %@", username).first

        if let u = user {

            try! realm.write {
                u.addGroup(self.selectedGroup.idGroup)
            }
        }

        objectUser.saveInBackground { (done: Bool, error: NSError?) -> Void in
            if error == nil {
                self.getContactsInGroup()
            }
        }

    }
    
    func deleteContact(_ contact : RealmUserModel) {
        let queryGetEvents = PFQuery(className: "Group_users")
        //queryGetEvents.whereKey("group_id", equalTo: selectedGroup.idGroup)
        queryGetEvents.order(byDescending: "createdAt")

        let realm = try! Realm()

        var user = realm.objects(RealmUserModel.self).filter("username = %@", contact.username).first

        if let u = user {

            try! realm.write {
                u.removeGroup(self.selectedGroup.idGroup)
            }
        }

        queryGetEvents.getObjectInBackground(withId: contact.objectId) { (object : PFObject?, error : NSError?) in
            object?.deleteInBackground(block: { (done: Bool, error: NSError?) in
                self.getContactsInGroup()
            })
        }

    }
    
    
    func getContactsInGroup() {

        let queryGetEvents = PFQuery(className: "Group_users")
        queryGetEvents.whereKey("group_id", equalTo: selectedGroup.idGroup)
        queryGetEvents.order(byAscending: "full_name")
        
        queryGetEvents.findObjectsInBackground { (objects : [PFObject]?, error: NSError?) in
            if error == nil {

                self.listOfContactsRemote.removeAll()

                self.listOfContacts = self.listOfAllContacts
                self.filteredListContacts = self.listOfAllContacts
                
                for object : PFObject in objects! {
                    
                    var imageUrl = ""
                    
                    if let photo = object.object(forKey: "photo") as? PFFile {
                        imageUrl = photo.url!
                    }
                    
                    
                    
                    for item : CNContact in self.listOfAllContacts {
                        if object.value(forKey: "full_name") as? String == CNContactFormatter().string(from: item) {
                            self.listOfContacts.removeObject(item)
                            self.filteredListContacts.removeObject(item)
                        }
                    }

                    let user = RealmUserModel(_objectId: object.objectId!, _userName: object.value(forKey: "username") as! String, _name: object.value(forKey: "full_name") as! String, _imageUrl: imageUrl, _isAdded: object.value(forKey: "in_app") as! Bool)

                    self.listOfContactsRemote.append(user)
                }
                self.textFieldDidChange(self.tfSearch)
                self.tableView.reloadData()
                
            }
        }
        
    }

}
