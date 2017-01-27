//
//  EditProfileViewController.swift
//  Unplanned
//
//  Created by matata on 05.06.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0
import Parse

class EditProfileViewController: BaseViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfBirthday: UITextField!
    @IBOutlet weak var imgViewPhoto: UIImageView!
    @IBOutlet weak var labelSelectPhoto: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var dateChanged = false
    
    var birthday = NSDate()
    
    override func viewDidLoad() {
        self.setupGradienNavigationBar("Edit Profile".localized())
        self.createNavigationBarButtons()
        
        super.viewDidLoad()
        self.labelSelectPhoto.text = "Upload photo".localized()
        self.tfFirstName.placeholder = "Name".localized()
        self.tfLastName.placeholder = "Last name".localized()
        self.tfBirthday.placeholder = "Birthday".localized()
        self.btnContinue.setTitle("Save".localized(), forState: .Normal)
        
        //imgViewPhoto.backgroundColor = UIColor.lightGrayColor()
        imgViewPhoto.layer.cornerRadius = imgViewPhoto.height() / 2
        //imgViewPhoto.contentMode = .ScaleAspectFill
        imgViewPhoto.clipsToBounds = true
        
        tfBirthday.delegate = self
        
        if let user = PFUser.currentUser()  {
            self.tfFirstName.text = user.valueForKey("firstName") as? String
            self.tfLastName.text = user.valueForKey("lastName") as? String
            
            if let photo = user.valueForKey("photo") as? PFFile {
                self.imgViewPhoto.kf_setImageWithURL(NSURL(string: photo.url!)!)
            }
            
            self.tfBirthday.text = (user.valueForKey("birthday") as? NSDate)!.mt_stringValueWithDateStyle(.MediumStyle, timeStyle: .NoStyle)
        }
        
        
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        super.touchesBegan(touches, withEvent: event)
        view.endEditing(true);
    }
    
    @IBAction func btnAddPhotoTap(sender: AnyObject) {
        view.endEditing(true)
        pickImage()
    }
    
    func setTFBirthday() {
        self.dateChanged = true
        tfBirthday.text = birthday.mt_stringValueWithDateStyle(.MediumStyle, timeStyle: .NoStyle)
    }
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool
    {
        view.endEditing(true)
        
        let doneBlock:ActionDateDoneBlock = { (picker, date, origin) in
            if let date = date as? NSDate { self.birthday = date }
            self.setTFBirthday()
        }
        
        ActionSheetDatePicker.showPickerWithTitle(appName(), datePickerMode: .Date, selectedDate: birthday, minimumDate: nil, maximumDate: NSDate(), doneBlock: doneBlock, cancelBlock: nil, origin: view)
        
        return false
    }
    
    @IBAction func btnContinueTap(sender: AnyObject)
    {
        
        if (((tfFirstName.text!.trim() == "") || (tfLastName.text!.trim() == "" ) || (tfBirthday.text!.trim() == ""))) {
            return
        }
        
        if let image = imgViewPhoto.image, imgData = UIImagePNGRepresentation(image)
        {
            let photo = PFFile(data: imgData, contentType: "image/png")
            hudShow()
            photo.saveInBackgroundWithBlock({ (success, error) in
                self.hudHide()
                guard success else {
                    UIMsg("Failed to save photo \(error?.localizedDescription ?? "")")
                    return
                }
                self.saveUser(photo)
            })
        }
        else {
            saveUser(nil)
        }
    }
    
    func saveUser(photo:PFFile?)
    {
        
        AppDelegate.delegate.setLoggedInVC(true)
        guard let user = UserModel.currentUser() as UserModel? else { return }
        
        
        user.firstName = tfFirstName.text
        user.lastName = tfLastName.text
        if (dateChanged) {
            user.birthday = birthday
        }
        if (photo != nil) {
            user.photo = photo
        }
        user.isProfileCreated = true
        
        hudShow()
        user.saveInBackgroundWithBlock { (success, error) in
            self.hudHide()
            guard success else {
                UIMsg("Failed to save profile \(error?.localizedDescription ?? "")")
                return
            }
            
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    
    // MARK: image picking
    
    func pickImage()
    {
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .SavedPhotosAlbum
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        presentViewController(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        imgViewPhoto.image = info[UIImagePickerControllerEditedImage] as? UIImage
        imgViewPhoto.contentMode = .ScaleAspectFill
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: dev facility
    override func hasDevFacilities() -> Bool {
        return true
    }
    
    override func setupDevFacilityActionSheet(sheet: UIAlertController)
    {
        let action = UIAlertAction(title: "Fill test data", style: .Default, handler: { (action) in
            self.tfFirstName.text = "Minch"
            self.tfLastName.text = "Yoda"
            self.birthday = NSDate.mt_dateFromYear(1900, month: 1, day: 1)
            self.setTFBirthday()
            self.imgViewPhoto.image = UIImage(named: "yoda.jpg")
        })
        sheet.addAction(action)
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
        
    }
    
    func close(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}
