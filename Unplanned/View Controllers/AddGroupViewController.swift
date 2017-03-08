//
//  AddGroupViewController.swift
//  Unplanned
//
//  Created by matata on 31.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse
import RealmSwift

class AddGroupViewController: BaseViewController {
    
    @IBOutlet weak var ivBackground: UIImageView!
    @IBOutlet weak var ivImageGroup: UIImageView!
    @IBOutlet weak var tfNameGroup: UITextField!
    
    var typeGroup = ""
    
    override func viewDidLoad() {
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setTransparentNavigationBar()
        self.createNavigationBarButtons()
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
        
        let gradientLayer = CAGradientLayer()
        
        let frame = ivBackground.bounds
        gradientLayer.frame = frame
        gradientLayer.colors = [UIColor(rgba: "#00BBEB"),UIColor(rgba: "#00CF97")].map{$0.cgColor}
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        // Render the gradient to UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivBackground.image = image
        
        self.navigationItem.title = "Create group".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.systemFont(ofSize: 17), NSForegroundColorAttributeName: UIColor.white]
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create".localized(), style: UIBarButtonItemStyle.plain, target: self, action: #selector(CreateEventViewController.submit(_:)))
        
    }
    
    func close(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    
    func submit(_ sender : UIButton) {
        self.createGroup()
    }
    
    
    @IBAction func openSelectImage(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "segueOpenSelectImages", sender: nil)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if segue.identifier == "segueOpenSelectImages"{
            let vc = segue.destination as! ListGroupImagesViewControler
            vc.delegate = self
        }
        
        if segue.identifier == "segueAddContactsToGroup" {
            let destinationVC = segue.destination as! AddContactsToGroupViewController
            
            let object = sender as! PFObject

            let group = GroupModel(_idGroup: object.objectId!, _titleGroup: object.value(forKey: "title") as! String, _typeGroup: object.value(forKey: "type") as! String, _imageUrlGroup: "group_\(object.value(forKey: "type") as! String)")

            let realm = try! Realm()

            try! realm.write {
                realm.add(group, update: true)
            }

            destinationVC.selectedGroup = group
        }
    }
    
    func createGroup() {
        
        if (self.tfNameGroup.text == "" || self.typeGroup == "") {
            return
        }
        self.hudShow()
        let objectEvent = PFObject(className: "Group")
        
        objectEvent.setValue(self.tfNameGroup.text?.capitalized, forKey: "title")
        objectEvent.setValue(self.typeGroup, forKey: "type")
        objectEvent.setObject(PFUser.current()!, forKey: "user")
        objectEvent.saveInBackground { (done: Bool, error: NSError?) -> Void in
            if error == nil {
                self.performSegue(withIdentifier: "segueAddContactsToGroup", sender: objectEvent)
            }
            self.hudHide()
        }
    }
}

extension AddGroupViewController : ImageGroupSelectControllerDelegate {
    func selectImageFinished(_ image: UIImage, type: String) {
        self.ivImageGroup.image = image
        self.typeGroup = type
    }
}
