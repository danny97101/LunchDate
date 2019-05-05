//
//  RequestController.swift
//  LunchDate
//
//  Created by Timothy Marotta on 4/29/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit
import Alamofire

class RequestController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var requestTableView: UITableView!
    @IBOutlet weak var requestTableHeight: NSLayoutConstraint!
    @IBOutlet weak var noNewRequests: UILabel!
    
    var requestUsernames: [String] = []
    var requestDisplayNames: [String] = []
    var requestIDs: [Int] = []
    
    @IBOutlet weak var friendTableView: UITableView!
    @IBOutlet weak var friendTableViewHeight: NSLayoutConstraint!
    
    var friendUsernames: [String] = []
    var friendDisplayNames: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        requestTableView.delegate = self
        requestTableView.dataSource = self
        friendTableView.delegate = self
        friendTableView.dataSource = self
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == requestTableView {
            return requestUsernames.count
        } else {
            return friendUsernames.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == requestTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friendrequest", for: indexPath) as! FriendRequestTableViewCell
            cell.nameLabel.text = requestDisplayNames[indexPath.item]
            cell.usernameLabel.text = requestUsernames[indexPath.item]
            cell.requestID = requestIDs[indexPath.item]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath) as! FriendTableViewCell
            cell.nameLabel.text = friendDisplayNames[indexPath.item]
            cell.usernameLabel.text = friendUsernames[indexPath.item]
            return cell
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        updateTables()
    }
    
    public func updateTables() {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            
            let userParam: Parameters = [
                "action" : "getFriendRequests",
                "token" : token!
            ]
            
            Alamofire.request(Config.host + "action.php", method: .post, parameters: userParam, encoding: URLEncoding.default).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    }
                case .success( _):
                    if let data = response.data, let responseString =  String(data: data, encoding: .utf8){
                        print(responseString)
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                                self.requestDisplayNames = []
                                self.requestUsernames = []
                                self.requestIDs = []
                                for request in json {
                                    let displayName = (request["display_name"] as! String).base64Decoded()
                                    let username = (request["username"] as! String).base64Decoded()
                                    let id = request["id"] as! Int
                                    self.requestDisplayNames.append(displayName!)
                                    self.requestUsernames.append(username!)
                                    self.requestIDs.append(id)
                                }
                                self.requestTableView.reloadData()
                               
                                if json.count == 0 {
                                    self.noNewRequests.isHidden = false
                                    self.requestTableHeight.constant = 129
                                } else {
                                    self.noNewRequests.isHidden = true
                                    self.requestTableHeight.constant = self.requestTableView.contentSize.height
                                }
                            }
                        } catch _ as NSError {
                            
                        }
                    }
                }
            }
            
            let friendParam: Parameters = [
                "action" : "getFriends",
                "token" : token!
            ]
            
            Alamofire.request(Config.host + "action.php", method: .post, parameters: friendParam, encoding: URLEncoding.default).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    }
                case .success( _):
                    if let data = response.data, let responseString =  String(data: data, encoding: .utf8){
                        print(responseString)
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                                self.friendDisplayNames = []
                                self.friendUsernames = []
                                for request in json {
                                    let displayName = (request["display_name"] as! String).base64Decoded()
                                    let username = (request["username"] as! String).base64Decoded()
                                    self.friendDisplayNames.append(displayName!)
                                    self.friendUsernames.append(username!)
                                }
                                self.friendTableView.reloadData()
                                
                                if json.count == 0 {
                                    //self.noNewRequests.isHidden = false
                                    self.friendTableViewHeight.constant = 129
                                } else {
                                    //self.noNewRequests.isHidden = true
                                    self.friendTableViewHeight.constant = self.friendTableView.contentSize.height
                                }
                            }
                        } catch _ as NSError {
                            
                        }
                    }
                }
            }
        }
    }
    
}


