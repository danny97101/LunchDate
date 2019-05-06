//
//  HomeController.swift
//  LunchDate
//
//  Created by Timothy Marotta on 4/12/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit
import EventKit
import Alamofire

class HomeController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "date", for: indexPath) as! DateTableViewCell
        cell.nameLabel.text = nameList[indexPath.item]
        cell.usernameLabel.text = usernameList[indexPath.item]
        cell.freeLabel.text = freeList[indexPath.item]
        return cell
    }
    
    var nameList: [String] = []
    var usernameList: [String] = []
    var freeList: [String] = []
    
    @IBOutlet weak var dateTable: UITableView!
    @IBOutlet weak var dateTableHeight: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dateTable.delegate = self
        dateTable.dataSource = self
        dateTable.allowsMultipleSelection = true
        dateTable.allowsMultipleSelectionDuringEditing = true
        
        let store = EKEventStore()
        
        // Do any additional setup after loading the view.
        let calendar = Calendar.current
        
        var day: Date? = nil
        var end: Date? = nil
        if calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date())! < Date() {
            var tomorrowComponents = DateComponents()
            tomorrowComponents.day = 1
            day = calendar.date(byAdding: tomorrowComponents, to: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!)
            end = calendar.date(byAdding: tomorrowComponents, to: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!)
        } else {
            var tomorrowComponents = DateComponents()
            tomorrowComponents.day = 0
            day = calendar.date(byAdding: tomorrowComponents, to: calendar.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!)
            end = calendar.date(byAdding: tomorrowComponents, to: calendar.date(bySettingHour: 14, minute: 0, second: 0, of: Date())!)
        }
        
        var predicate: NSPredicate? = nil
        if let aNow = day, let aTomorrow = end {
            predicate = store.predicateForEvents(withStart: aNow, end: aTomorrow, calendars: nil)
        }
        
        
        var events: [EKEvent]? = nil
        if let aPredicate = predicate {
            events = store.events(matching: aPredicate)
            if let aEvents = events {
                let dateFormatter = DateFormatter()
                var uploadString = ""
                dateFormatter.dateFormat = "HH:mm"
                if (aEvents.count > 0 && dateFormatter.string(from: aEvents[0].startDate) != "11:00") || aEvents.count==0 {
                    uploadString += "11:00-"
                }
                var startDate: String? = nil
                var endDate: String? = nil
                for event in aEvents {
                    startDate = dateFormatter.string(from: event.startDate)
                    endDate = dateFormatter.string(from: event.endDate)
                    if startDate != "11:00" {
                        uploadString +=  startDate! + ","
                    }
                    if endDate != "2:00" {
                        uploadString += endDate! + "-"
                    }
                }
                uploadString += "2:00"
                let defaults = UserDefaults.standard
                let token = defaults.string(forKey: "token")
                if token != nil {
                    let parameters: Parameters = [
                        "action" : "uploadCalendar",
                        "token" : token!,
                        "events" : uploadString
                    ]
                    
                    Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
                        
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        let friendParam: Parameters = [
            "action" : "getPotentialDates",
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
//                            self.friendDisplayNames = []
//                            self.friendUsernames = []
                            self.nameList = []
                            self.usernameList = []
                            self.freeList = []
                            
                            for request in json {
                                let displayName = (request["display_name"] as! String).base64Decoded()
                                let username = (request["username"] as! String).base64Decoded()
                                let freeTimes = request["available_times"] as! String
                                self.nameList.append(displayName!)
                                self.usernameList.append(username!)
                                self.freeList.append("Free: " + freeTimes)
//                                self.friendDisplayNames.append(displayName!)
//                                self.friendUsernames.append(username!)
                            }
//                            self.friendTableView.reloadData()
                            self.dateTable.reloadData()
                            
                            
                            if json.count == 0 {
                                //self.noNewRequests.isHidden = false
//                                self.friendTableViewHeight.constant = 129
                                self.dateTableHeight.constant = 129
                            } else {
                                //self.noNewRequests.isHidden = true
//                                self.friendTableViewHeight.constant = self.friendTableView.contentSize.height
                                self.dateTableHeight.constant = self.dateTable.contentSize.height
                            }
                        }
                    } catch _ as NSError {
                        
                    }
                }
            }
        }
    }

}

