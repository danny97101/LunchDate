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
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        if token != nil {
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
                                for i in 0..<self.isAllergic.count {
                                    self.table.cellForRow(at: IndexPath(item: i, section: 0))?.setSelected(self.isAllergic[i], animated: true)
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
