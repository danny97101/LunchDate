//
//  WelcomeController.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 4/21/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit
import Alamofire
import EventKit

class WelcomeController: UIViewController {
    
    let eventStore = EKEventStore()
    
    override func viewWillAppear(_ animated: Bool) {
        checkCalendarAuthorizationStatus()
    }
    
    func checkCalendarAuthorizationStatus() {
        let status = EKEventStore.authorizationStatus(for: EKEntityType.event)
        
        switch (status) {
        case EKAuthorizationStatus.notDetermined:
            // This happens on first-run
            requestAccessToCalendar()
        case EKAuthorizationStatus.authorized:
            // Things are in line with being able to show the calendars in the table view
            break
        case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
            // We need to help them give us permission
            let alert = UIAlertController(title: "Calendar Access Required", message: "This app requires access to your calendar. In order to use it, please grant calendar access in the Settings app.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true)
        }
    }
    
    func requestAccessToCalendar() {
        eventStore.requestAccess(to: EKEntityType.event, completion: {
            (accessGranted: Bool, error: Error?) in
            
            if accessGranted == true {

            } else {
                let alert = UIAlertController(title: "Calendar Access Required", message: "This app requires access to your calendar. In order to use it, please grant calendar access in the Settings app.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let defaults = UserDefaults.standard
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
