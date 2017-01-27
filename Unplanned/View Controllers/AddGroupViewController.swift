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
    
    override func viewWillAppear(animated: Bool) {
        self.setTransparentNavigationBar()
        self.createNavigationBarButtons()
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
        
        let gradientLayer = CAGradientLayer()
        
        let frame = ivBackground.bounds
        gradientLayer.frame = frame
        gradientLayer.colors = [UIColor(rgba: "#00BBEB"),UIColor(rgba: "#00CF97")].map{$0.CGColor}
        gradientLayer.startPoint = CGPoint(x: 1.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 0.0, y: 1.0)
        
        // Render the gradient to UIImage
        UIGraphicsBeginImageContext(gradientLayer.bounds.size)
        gradientLayer.renderInContext(UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        ivBackground.image = image
        
        self.navigationItem.title = "Create group".localized()
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont.systemFontOfSize(17), NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Create".localized(), style: UIBarButtonItemStyle.Plain, target: self, action: #selector(CreateEventViewController.submit(_:)))
        
    }
    
    func close(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    
    
    func submit(sender : UIButton) {
        self.createGroup()
    }
    
    
    @IBAction func openSelectImage(sender: AnyObject) {
        self.performSegueWithIdentifier("segueOpenSelectImages", sender: nil)
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "segueOpenSelectImages"{
            let vc = segue.destinationViewController as! ListGroupImagesViewControler
            vc.delegate = self
        }
        
        if segue.identifier == "segueAddContactsToGroup" {
            let destinationVC = segue.destinationViewController as! AddContactsToGroupViewController
            
            let object = sender as! PFObject

            let group = GroupModel(_idGroup: object.objectId!, _titleGroup: object.valueForKey("title") as! String, _typeGroup: object.valueForKey("type") as! String, _imageUrlGroup: "group_\(object.valueForKey("type") as! String)")

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
        
        objectEvent.setValue(self.tfNameGroup.text?.capitalizedString, forKey: "title")
        objectEvent.setValue(self.typeGroup, forKey: "type")
        objectEvent.setObject(PFUser.currentUser()!, forKey: "user")
        objectEvent.saveInBackgroundWithBlock { (done: Bool, error: NSError?) -> Void in
            if error == nil {
                self.performSegueWithIdentifier("segueAddContactsToGroup", sender: objectEvent)
            }
            self.hudHide()
        }
    }
}

extension AddGroupViewController : ImageGroupSelectControllerDelegate {
    func selectImageFinished(image: UIImage, type: String) {
        self.ivImageGroup.image = image
        self.typeGroup = type
    }
}
