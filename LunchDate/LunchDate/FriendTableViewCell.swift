//
//  FriendTableViewCell.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 5/5/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import Foundation
import Foundation
import UIKit
import Alamofire

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var statusPic: UIImageView!
    @IBAction func remove(_ sender: Any) {
        if removeButton.currentTitle == "Remove" {
            var message = "Are you sure you want to remove "
            message += (nameLabel.text)!
            message += "(" + (usernameLabel.text)! + ") as a friend?"
            
            let alert = UIAlertController(title: "Remove Friend", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Remove", style: .destructive, handler: self.removeFriend))
            self.parentViewController?.present(alert, animated: true)
        } else {
            var message = "Are you sure you want to add "
            message += (nameLabel.text)!
            message += "(" + (usernameLabel.text)! + ") as a friend?"
            
            let alert = UIAlertController(title: "Add Friend", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "Add", style: .default, handler: self.addFriend))
            self.parentViewController?.present(alert, animated: true)
        }
    }
    
    public func removeFriend(action: UIAlertAction) {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            let parameters: Parameters = [
                "action": "removeFriend",
                "token": token!,
                "username": usernameLabel.text!
            ]
            Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    }
                case .success( _):
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                        let controller = self.parentViewController as! RequestController
                        controller.updateTables()
                    }
                }
            }
        }
    }
    public func addFriend(action: UIAlertAction) {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            let parameters: Parameters = [
                "action": "addFriend",
                "token": token!,
                "username": usernameLabel.text!
            ]
            Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    }
                case .success( _):
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                        let controller = self.parentViewController as! SearchController
                        controller.updateSearchResults(for: controller.searchController)
                    }
                }
            }
        }
    }
}
