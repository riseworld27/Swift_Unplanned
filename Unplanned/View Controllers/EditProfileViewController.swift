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
    
    var birthday = Date()
    
    override func viewDidLoad() {
        self.setupGradienNavigationBar("Edit Profile".localized())
        self.createNavigationBarButtons()
        
        super.viewDidLoad()
        self.labelSelectPhoto.text = "Upload photo".localized()
        self.tfFirstName.placeholder = "Name".localized()
        self.tfLastName.placeholder = "Last name".localized()
        self.tfBirthday.placeholder = "Birthday".localized()
        self.btnContinue.setTitle("Save".localized(), for: UIControlState())
        
        //imgViewPhoto.backgroundColor = UIColor.lightGrayColor()
        imgViewPhoto.layer.cornerRadius = imgViewPhoto.height() / 2
        //imgViewPhoto.contentMode = .ScaleAspectFill
        imgViewPhoto.clipsToBounds = true
        
        tfBirthday.delegate = self
        
        if let user = PFUser.current()  {
            self.tfFirstName.text = user.value(forKey: "firstName") as? String
            self.tfLastName.text = user.value(forKey: "lastName") as? String
            
            if let photo = user.value(forKey: "photo") as? PFFile {
                self.imgViewPhoto.kf_setImageWithURL(URL(string: photo.url!)!)
            }
            
            self.tfBirthday.text = ((user.value(forKey: "birthday") as? Date)! as NSDate).mt_stringValue(withDateStyle: .medium, time: .none)
        }
        
        
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        view.endEditing(true);
    }
    
    @IBAction func btnAddPhotoTap(_ sender: AnyObject) {
        view.endEditing(true)
        pickImage()
    }
    
    func setTFBirthday() {
        self.dateChanged = true
        tfBirthday.text = (birthday as NSDate).mt_stringValue(withDateStyle: .medium, time: .none)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool
    {
        view.endEditing(true)
        
        let doneBlock:ActionDateDoneBlock = { (picker, date, origin) in
            if let date = date as? Date { self.birthday = date }
            self.setTFBirthday()
        }
        
        ActionSheetDatePicker.show(withTitle: appName(), datePickerMode: .date, selectedDate: birthday, minimumDate: nil, maximumDate: Date(), doneBlock: doneBlock, cancel: nil, origin: view)
        
        return false
    }
    
    @IBAction func btnContinueTap(_ sender: AnyObject)
    {
        
        if (((tfFirstName.text!.trim() == "") || (tfLastName.text!.trim() == "" ) || (tfBirthday.text!.trim() == ""))) {
            return
        }
        
        if let image = imgViewPhoto.image, let imgData = UIImagePNGRepresentation(image)
        {
            let photo = PFFile(data: imgData, contentType: "image/png")
            hudShow()
            photo.saveInBackground(block: { (success, error) in
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
    
    func saveUser(_ photo:PFFile?)
    {
        
        AppDelegate.delegate.setLoggedInVC(true)
        guard let user = UserModel.current() as UserModel? else { return }
        
        
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
        user.saveInBackground { (success, error) in
            self.hudHide()
            guard success else {
                UIMsg("Failed to save profile \(error?.localizedDescription ?? "")")
                return
            }
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    
    
    // MARK: image picking
    
    func pickImage()
    {
        let imgPicker = UIImagePickerController()
        imgPicker.sourceType = .savedPhotosAlbum
        imgPicker.delegate = self
        imgPicker.allowsEditing = true
        present(imgPicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imgViewPhoto.image = info[UIImagePickerControllerEditedImage] as? UIImage
        imgViewPhoto.contentMode = .scaleAspectFill
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: dev facility
    override func hasDevFacilities() -> Bool {
        return true
    }
    
    override func setupDevFacilityActionSheet(_ sheet: UIAlertController)
    {
        let action = UIAlertAction(title: "Fill test data", style: .default, handler: { (action) in
            self.tfFirstName.text = "Minch"
            self.tfLastName.text = "Yoda"
            self.birthday = NSDate.mt_date(fromYear: 1900, month: 1, day: 1)
            self.setTFBirthday()
            self.imgViewPhoto.image = UIImage(named: "yoda.jpg")
        })
        sheet.addAction(action)
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
