//
//  FriendsListViewController.swift
//  Unplanned
//
//  Created by True Metal on 5/27/16.
//  Copyright © 2016 matata. All rights reserved.
//

import UIKit
import Parse

class FriendsListViewController: BaseViewController, UITableViewDataSource
{
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
    }
    
    var friends = Array<UserModel>()
    func loadData()
    {
        guard let friends = UserModel.currentUser()?.allFriends as? [PFObject] else { return }
        let castedFriends = friends.map { UserModel(withoutDataWithClassName: UserModel.parseClassName(), objectId: $0.objectId!) }
        
        hudShow()
        UserModel.fetchAllInBackground(castedFriends, block: { (fetchedFriends, error) in
            self.hudHide()
            guard let friends = fetchedFriends as? [UserModel] else { UIMsg("Failed to fetch friends \(error?.localizedDescription ?? "")"); return }
            self.friends = friends
            self.tableView.reloadData()
        })
    }
    
    // MARK: table view
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    let cellReuse = "friend"
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuse, forIndexPath: indexPath)
        
        let friend = friends[indexPath.row]
        cell.textLabel?.text = friend.fullName
        cell.detailTextLabel?.text = friend.username
        
        return cell
    }
}
