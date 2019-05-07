//
//  DateRequestCell.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 5/7/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class DateRequestCell: UITableViewCell {
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var whoStack: UIStackView!
    @IBOutlet weak var Accept: UIButton!
    @IBOutlet weak var Reject: UIButton!
    
    @IBOutlet weak var whoHeight: NSLayoutConstraint!
    var dateID = -1
    
    @IBAction func acceptRequest(_ sender: Any) {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            let parameters: Parameters = [
                "action": "respondToDateRequest",
                "token": token!,
                "request_id": dateID,
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
                        let controller = self.parentViewController as! NotificationController
                        let nav = controller.navigationController
                        nav?.popViewController(animated: true)
                        
                    }
                }
            }
        }
    }
    @IBAction func rejectRequest(_ sender: Any) {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            let parameters: Parameters = [
                "action": "respondToDateRequest",
                "token": token!,
                "request_id": dateID,
                "response": 2
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
                        let controller = self.parentViewController as! NotificationController
                        controller.updateTable()
                    }
                }
            }
        }
    }
}
