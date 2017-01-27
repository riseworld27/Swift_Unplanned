//
//  ListGroupImagesViewControler.swift
//  Unplanned
//
//  Created by matata on 31.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit

protocol ImageGroupSelectControllerDelegate{
    func selectImageFinished(image:UIImage, type: String)
}

class ListGroupImagesViewControler: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    
     var delegate:ImageGroupSelectControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    let listOfImages = ["group_Family","group_Work", "group_School", "group_Friends", "group_Other"]
    let listOfTitles = ["Family", "Work", "School", "Friends", "Other"]
    
    
    
    
    override func viewDidLoad() {
        self.createNavigationBarButtons()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.setupGradienNavigationBar("Group icon".localized())
        
        
        tableView.contentInset = UIEdgeInsets(top: -64, left: 0, bottom: 0, right: 0)
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
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GroupListTableViewCell") as! GroupListTableViewCell
        
        cell.labelTitle.text = self.listOfTitles[indexPath.row].localized()
        cell.ivPicture.image = UIImage(named: self.listOfImages[indexPath.row])
        
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
         self.delegate?.selectImageFinished(UIImage(named: self.listOfImages[indexPath.row])!, type: listOfTitles[indexPath.row])
        
        self.navigationController?.popViewControllerAnimated(true)
    }
}
