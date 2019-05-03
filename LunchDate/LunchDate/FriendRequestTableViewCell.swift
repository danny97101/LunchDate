//
//  FriendRequestTableViewCell.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 5/3/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class FriendRequestTableViewCell: UITableViewCell {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    var requestID: Int? = nil
    
    @IBAction func addFriend(_ sender: Any) {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            let parameters: Parameters = [
                "action": "respondToFriendRequest",
                "token": token!,
                "request_id": requestID!,
                "response": 1
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
    @IBAction func declineFriend(_ sender: Any) {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            let parameters: Parameters = [
                "action": "respondToFriendRequest",
                "token": token!,
                "request_id": requestID!,
                "response": 0
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
}

extension UIView {
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}
