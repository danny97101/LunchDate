//
//  LoginController.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 4/26/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class LoginController: UIViewController {
    
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernameField.becomeFirstResponder()
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
    
    @IBAction func login(_ sender: Any) {
        let parameters: Parameters = [
            "action": "login",
            "username": usernameField.text ?? "",
            "password": passwordField.text ?? ""
        ]
        
        Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            switch response.result {
            case .failure(let error):
                print(error)
                
                if let data = response.data, let responseString = String(data: data, encoding: .utf8) {
                    print(responseString)
                }
                if response.response?.statusCode == 401 {
                    let alert = UIAlertController(title: "Try Again", message: "The username and password do not match.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            case .success( _):
                if let data = response.data {
                    var success = true
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String : Any] {
                            let defaults = UserDefaults.standard
                            if let token = json["token"] as? String {
                                defaults.set(token, forKey: "token")
                            } else {
                                success = false
                            }
                            if let b64EncName = json["display_name"] as? String {
                                defaults.set(b64EncName.base64Decoded(), forKey: "display_name")
                            } else {
                                success = false
                            }
                            if let b64EncUsername = json["username"] as? String {
                                defaults.set(b64EncUsername.base64Decoded(), forKey: "username")
                            } else {
                                success = false
                            }
                        }
                    } catch _ as NSError {
                        success = false
                    }
                    if success {
                        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                        //let tabViewController = storyBoard.instantiateViewController(withIdentifier: "tab") as! MainTabController
                        let navViewController = storyBoard.instantiateViewController(withIdentifier: "prettyboi") as! PrettyBoi
                        //let tabViewController = navViewController.viewControllers[0] as! MainTabController
                        self.present(navViewController, animated: true, completion: {
                            self.navigationController?.popToRootViewController(animated: false)
                        })
                        
                    }
                }
                
            }
        }
    }
}
