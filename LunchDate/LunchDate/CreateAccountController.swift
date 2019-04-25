//
//  FirstViewController.swift
//  LunchDate
//
//  Created by Timothy Marotta on 4/12/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit
import Alamofire

class CreateAccountController: UIViewController {
//    @IBOutlet weak var allergenPickerView: UIPickerView!
//
//    func numberOfComponents(in pickerView: UIPickerView) -> Int {
//        return 1;
//    }
//
//    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
//        return allergens.count;
//    }
//
//    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
//        return allergens[row]
//    }
    
//    var allergens: [String] = []
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var confirmField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameField.becomeFirstResponder()
        
//        allergenPickerView.dataSource = self
//        allergenPickerView.delegate = self
//
//        let parameters: Parameters = ["action": "getAllergens"]
//
//        Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
//            switch response.result {
//            case .failure(let error):
//                print(error)
//
//                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
//                    print(responseString)
//                }
//            case .success( _):
//                if let data = response.data {
//                    do {
//                        self.allergens = []
//                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
//                            for element in json {
//                                if let name = element["name"] as? String {
//                                    self.allergens.append(name)
//                                }
//                            }
//                        }
//                        self.allergenPickerView.reloadAllComponents()
//                    } catch _ as NSError {
//                        return
//                    }
//                }
//            }
//        }
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
    
    @IBAction func createAccount(_ sender: Any) {
        let name = nameField.text ?? ""
        let username = usernameField.text ?? ""
        let password = passwordField.text ?? ""
        let confirm = confirmField.text ?? ""
        if name == "" || username == "" || password == "" {
            let alert = UIAlertController(title: "Missing Information", message: "Please enter your Name, Username, and Password.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
            self.present(alert, animated: true)
        } else {
            if password != confirm {
                let alert = UIAlertController(title: "Passwords Don't Match", message: "The passwords entered in the \"Password\" and \"Confirm Password\" fields don't match.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
                self.present(alert, animated: true)
            } else {
                let parameters: Parameters = [
                    "action": "createUser",
                    "display_name": name,
                    "username": username,
                    "password": password
                ]
                
                Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                    switch response.result {
                    case .failure(let error):
                        print(error)
                        
                        if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                            print(responseString)
                        }
                    case .success( _):
                        if let data = response.data {
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                                    print(json)
                                }
                            } catch _ as NSError {
                                return
                            }
                        }
                        
                    }
                }
            }
        }
    }
}

