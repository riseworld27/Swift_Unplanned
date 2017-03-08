//
//  ListGroupImagesViewControler.swift
//  Unplanned
//
//  Created by matata on 31.05.16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit

protocol ImageGroupSelectControllerDelegate{
    func selectImageFinished(_ image:UIImage, type: String)
}

class ListGroupImagesViewControler: BaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    
     var delegate:ImageGroupSelectControllerDelegate?
    
    @IBOutlet weak var tableView: UITableView!
    
    let listOfImages = ["group_Family","group_Work", "group_School", "group_Friends", "group_Other"]
    let listOfTitles = ["Family", "Work", "School", "Friends", "Other"]
    
    
    
    
    override func viewDidLoad() {
        self.createNavigationBarButtons()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setupGradienNavigationBar("Group icon".localized())
        
        
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
        return self.listOfTitles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupListTableViewCell") as! GroupListTableViewCell
        
        cell.labelTitle.text = self.listOfTitles[indexPath.row].localized()
        cell.ivPicture.image = UIImage(named: self.listOfImages[indexPath.row])
        
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         self.delegate?.selectImageFinished(UIImage(named: self.listOfImages[indexPath.row])!, type: listOfTitles[indexPath.row])
        
        self.navigationController?.popViewController(animated: true)
    }
}
