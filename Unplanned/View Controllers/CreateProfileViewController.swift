//
//  CreateProfileViewController.swift
//  Unplanned
//
//  Created by True Metal on 5/26/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import UIView_TKGeometry
import MTDates
import ActionSheetPicker_3_0
import Parse
import DigitsKit
import UIColor_Hex_Swift
import SideMenu

class CreateProfileViewController: BaseViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var tfBirthday: UITextField!
    @IBOutlet weak var imgViewPhoto: UIImageView!
    @IBOutlet weak var tvOfferta: UITextView!
    @IBOutlet weak var labelSelectPhoto: UILabel!
    @IBOutlet weak var btnContinue: UIButton!
    
    var birthday = Date()
    
    var imageChanged = false
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.labelSelectPhoto.text = "Upload photo".localized()
        self.tfFirstName.placeholder = "Name".localized()
        self.tfLastName.placeholder = "Last name".localized()
        self.tfBirthday.placeholder = "Birthday".localized()
        self.btnContinue.setTitle("Continue".localized(), for: UIControlState())
        
        //imgViewPhoto.backgroundColor = UIColor.lightGrayColor()
        imgViewPhoto.layer.cornerRadius = imgViewPhoto.height() / 2
        //imgViewPhoto.contentMode = .ScaleAspectFill
        imgViewPhoto.clipsToBounds = true
        
        tfBirthday.delegate = self
        self.createPrivacyText()
        self.setupGradienNavigationBar("Registro")
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
            var photo = PFFile(data: imgData, contentType: "image/png")
            
            if !imageChanged {
                photo = PFFile(data: UIImagePNGRepresentation(UIImage(named: "icon_no_user")!)!, contentType: "image/png")
            }
            
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
        user.birthday = birthday
        user.photo = photo
        user.isProfileCreated = true
        
        hudShow()
        user.saveInBackground { (success, error) in
            self.hudHide()
            guard success else {
                UIMsg("Failed to save profile \(error?.localizedDescription ?? "")")
                return
            }
        registerPFUserForPushNotifications(PFUser.current()!)
            self.uploadFriendsAndFinish()
        }
    }
    
    func uploadFriendsAndFinish()
    {
        if Digits.sharedInstance().session() != nil {
            hudShow()
            FriendsFinderHelper.startMatchingParseFriendsWithDigits(sendNotificationsToMatchedUsers: false, completionBlock: {
                self.hudHide()
                AppDelegate.delegate.setLoggedInVC(true)
            })

        } else {
            AppDelegate.delegate.setLoggedInVC(true)
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
        self.imageChanged = true
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
    
    func createPrivacyText(){
        
        //attributes for text agreemenents
        var whitTextAttributes = [String : NSObject]()
        //whitTextAttributes[NSFontAttributeName] = UIFont(name: "OpenSans", size: 12)
        whitTextAttributes[NSForegroundColorAttributeName] = UIColor.lightGray

        var linkAttributeTerms = [String : NSObject]()
        linkAttributeTerms[NSLinkAttributeName] = "http://google.com" as NSObject?
        linkAttributeTerms[NSUnderlineStyleAttributeName] = NSNumber(value: true as Bool)
        linkAttributeTerms[NSForegroundColorAttributeName] = UIColor(rgba: "#9C9C9C")
        linkAttributeTerms[NSFontAttributeName] = UIFont.systemFont(ofSize: 12)
        
        var linkAttributePrivacy = [String : NSObject]()
        linkAttributePrivacy[NSLinkAttributeName] = "http://google.com" as NSObject?
        linkAttributePrivacy[NSUnderlineStyleAttributeName] = NSNumber(value: true as Bool)
        linkAttributePrivacy[NSForegroundColorAttributeName] = UIColor(rgba: "#FFBDE1")
        linkAttributePrivacy[NSFontAttributeName] = UIFont.systemFont(ofSize: 12)
        //parts of full string
        let attributedStringStart = NSAttributedString(string: "\("By registering you are accepting the".localized())\n", attributes: whitTextAttributes)
        let space = NSAttributedString(string: " and ".localized(), attributes:  whitTextAttributes)
        let linkTerms = NSAttributedString(string: "Terms and conditions".localized(), attributes: linkAttributeTerms)
        let linkPrivacy = NSAttributedString(string: "Privacy Policy".localized(), attributes: linkAttributePrivacy)
        let tmpStr : NSMutableAttributedString = attributedStringStart.mutableCopy() as! NSMutableAttributedString
        
        tmpStr.append(linkTerms)
        tmpStr.append(space)
        tmpStr.append(linkPrivacy)
        tvOfferta.attributedText = tmpStr
        tvOfferta.textAlignment = .center
        
        tvOfferta.dataDetectorTypes = UIDataDetectorTypes.link
        //textOfferta.editable = false;

    }
    
}

extension String
{
    func trim() -> String
    {
        return self.trimmingCharacters(in: CharacterSet.whitespaces)
    }
}
