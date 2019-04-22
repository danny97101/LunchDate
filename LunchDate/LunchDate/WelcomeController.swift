//
//  WelcomeController.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 4/21/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit
import Alamofire

class WelcomeController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
        defaults.set("testtoken", forKey: "token")
        let token = defaults.string(forKey: "token")
        if token != nil {
            let parameters: Parameters = [
                "action" : "checkToken",
                "token" : token!
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
                                                if json["user"] as? Int != -1 {
                                                    let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                                    let tabViewController = storyBoard.instantiateViewController(withIdentifier: "tab") as! MainTabController
                                                    self.present(tabViewController, animated: false, completion: nil)
                                                }
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
