//
//  FirstViewController.swift
//  LunchDate
//
//  Created by Timothy Marotta on 4/12/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit
import Alamofire

class CreateAccountController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    @IBOutlet weak var allergenPickerView: UIPickerView!
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1;
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return allergens.count;
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return allergens[row]
    }
    
    var allergens: [String] = []
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        allergenPickerView.dataSource = self
        allergenPickerView.delegate = self
        
        let parameters: Parameters = ["action": "getAllergens"]
        
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
                        self.allergens = []
                        if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                            for element in json {
                                if let name = element["name"] as? String {
                                    self.allergens.append(name)
                                }
                            }
                        }
                        self.allergenPickerView.reloadAllComponents()
                    } catch _ as NSError {
                        return
                    }
                }
            }
        }
    }


}

