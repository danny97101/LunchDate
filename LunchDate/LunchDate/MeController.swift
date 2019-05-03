//
//  MeController.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 5/3/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class MeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableViewHeightConstraint: NSLayoutConstraint!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return pickerData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customcell", for: indexPath) as! CheckableTableViewCell
        cell.textLabel?.text = pickerData[indexPath.item]
        return cell
    }
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var table: UITableView!
    
    var pickerData: [String] = []
    var isAllergic: [Bool] = []
    


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.table.delegate = self
        self.table.dataSource = self
        self.table.allowsMultipleSelection = true
        self.table.allowsMultipleSelectionDuringEditing = true
        self.table.register(CheckableTableViewCell.self, forCellReuseIdentifier: "customcell")

        
    }
    


    
    override func viewDidAppear(_ animated: Bool) {
        getUserData()
    }
    @IBAction func saveChanges(_ sender: Any) {
        let name = nameField.text ?? ""
        let username = usernameField.text ?? ""
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            var parameters: Parameters = [
                "action": "updateUser",
                "token": token!,
                "display_name": name,
                "username": username,
            ]
            
            for i in 0..<self.isAllergic.count {
                let cell = self.table.cellForRow(at: IndexPath(item: i, section: 0))
                let allergen = cell?.textLabel?.text
                if cell?.isSelected ?? false {
                    parameters.updateValue(1, forKey: allergen!)
                } else {
                    parameters.updateValue(0, forKey: allergen!)
                }
            }
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
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                                if let success = json["success"] as? Int {
                                    if success == 0 {
                                        let alert = UIAlertController(title: "Couldn't Update", message: "There was a problem updating user info. Either the requested username is already taken or no name was inputted.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
                                        self.present(alert, animated: true)
                                    } else {
                                        let alert = UIAlertController(title: "Update Successful", message: "User info was successfully updated.", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                                        self.present(alert, animated: true)
                                    }
                                }
                            }
                        } catch _ as NSError {
                            
                        }
                    }
                }
                self.getUserData()
            }
        }
    }
    
    @IBAction func username(_ sender: Any) {
        let ind = usernameField.text?.firstIndex(of: "@")
        if ind == nil || ind! != usernameField.text?.startIndex {
            usernameField.text = "@" + (usernameField.text ?? "")
        }
    }
    @IBAction func editingEnd(_ sender: Any) {
        if (usernameField.text?.count ?? 0) <= 1 {
            usernameField.text = ""
        }
    }
    
    public func getUserData() {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
            
            let userParam: Parameters = [
                "action" : "getUserInfo",
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
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                                if let user = json["user"] as? [String : Any] {
                                    self.nameField.text = (user["display_name"] as? String)?.base64Decoded()
                                    self.usernameField.text = (user["username"] as? String)?.base64Decoded()
                                }
                            }
                        } catch _ as NSError {
                            
                        }
                    }
                }
            }
            
            
            
            
            
            let parameters: Parameters = [
                "action" : "getAllergensForUser",
                "token" : token!,
            ]
            
            Alamofire.request(Config.host + "action.php", method: .get, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                switch response.result {
                case .failure(let error):
                    print(error)
                    
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                    }
                case .success( _):
                    if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                        print(responseString)
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                                self.pickerData = []
                                self.isAllergic = []
                                for allergen in json {
                                    self.pickerData.append(allergen["name"] as! String)
                                    self.isAllergic.append(allergen["allergic"] as! Int == 1)
                                }
                                self.table.reloadData()
                                self.tableViewHeightConstraint.constant = self.table.contentSize.height
                                for i in 0..<self.isAllergic.count {
                                    let indexPath = IndexPath(item: i, section: 0)
                                    if self.isAllergic[i]{
                                        self.table.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
                                    }
                                }
                            }
                        }
                        catch _ as NSError {
                            
                        }
                    }
                }
            }
        }
    }
}

class CheckableTableViewCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
    }
}
