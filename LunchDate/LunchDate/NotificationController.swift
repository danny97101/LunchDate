//
//  Notifications.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 5/7/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class NotificationController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var table: UITableView!
    
    var whereList: [String] = []
    var whenList: [String] = []
    var whoList: [[String]] = []
    var dateIDList: [Int] = []

    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return whereList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "daterequest", for: indexPath) as! DateRequestCell
        cell.locationLabel.text = whereList[indexPath.item]
        cell.timeLabel.text = whenList[indexPath.item]
        for username in whoList[indexPath.item] {
            let label = UILabel()
            label.text = username
            cell.whoStack.addArrangedSubview(label)
        }
        cell.dateID = dateIDList[indexPath.item]
        cell.whoHeight.constant = CGFloat(20 * whoList[indexPath.item].count)
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func updateTable() {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        
        let parameters: Parameters = [
            "action": "getDateRequests",
            "token": token!
        ]
        
        Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            //            let tab = self.navigationController?.viewControllers[0] as! MainTabController
            //            let home = tab.selectedViewController as! HomeController
            //            home.loadDate()
            self.whenList = []
            self.whoList = []
            self.whereList = []
            self.dateIDList = []
            
            if let data = response.data, let responseString =  String(data: data, encoding: .utf8){
                print(responseString)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                        if json.count > 0 {
                            
                            
                            for u in json {
                                
                                let username = (u["username"] as! String).base64Decoded()
                                let id = u["id"] as! Int
                                let ind = self.dateIDList.firstIndex(of: id)
                                if let i = ind {
                                    self.whoList[i].append(username!)
                                } else {
                                    self.dateIDList.append(id)
                                    self.whoList.append([username!])
                                    self.whereList.append(u["dining_hall"] as! String)
                                    let dateStr = u["date_date"] as! String
                                    let dateFormatter = DateFormatter()
                                    dateFormatter.timeZone = .current
                                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                    let date = dateFormatter.date(from: dateStr)
                                    let betterFormatter = DateFormatter()
                                    betterFormatter.timeZone = .current
                                    betterFormatter.dateFormat = "h:mm a"
                                    betterFormatter.amSymbol = "AM"
                                    betterFormatter.pmSymbol = "PM"
                                    let myCalendar = Calendar(identifier: .gregorian)
                                    let weekDay = myCalendar.component(.weekday, from: date!)
                                    var dayStr = ""
                                    switch weekDay {
                                    case 1:
                                        dayStr = "Sunday "
                                        break
                                    case 2:
                                        dayStr = "Monday "
                                        break
                                    case 3:
                                        dayStr = "Tuesday "
                                        break
                                    case 4:
                                        dayStr = "Wednesday "
                                        break
                                    case 5:
                                        dayStr = "Thursday "
                                        break
                                    case 6:
                                        dayStr = "Friday "
                                        break
                                    default:
                                        dayStr = "Saturday "
                                    }
                                    
                                    self.whenList.append(betterFormatter.string(from: date!))
                                }
                            }
                            
                            
                            
                            
                            
                            
                            
                            
                            let dateStr = json[0]["date_date"] as! String
                            let dateFormatter = DateFormatter()
                            dateFormatter.timeZone = .current
                            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                            let date = dateFormatter.date(from: dateStr)
                            let betterFormatter = DateFormatter()
                            betterFormatter.timeZone = .current
                            betterFormatter.dateFormat = "h:mm a"
                            betterFormatter.amSymbol = "AM"
                            betterFormatter.pmSymbol = "PM"
                            let myCalendar = Calendar(identifier: .gregorian)
                            let weekDay = myCalendar.component(.weekday, from: date!)
                            var dayStr = ""
                            switch weekDay {
                            case 1:
                                dayStr = "Sunday "
                                break
                            case 2:
                                dayStr = "Monday "
                                break
                            case 3:
                                dayStr = "Tuesday "
                                break
                            case 4:
                                dayStr = "Wednesday "
                                break
                            case 5:
                                dayStr = "Thursday "
                                break
                            case 6:
                                dayStr = "Friday "
                                break
                            default:
                                dayStr = "Saturday "
                            }
                            
                            //                            self.whenLabel.text = dayStr + betterFormatter.string(from: date!)
                            //                            self.whereLabel.text = json[0]["dining_hall"] as? String
                            //                            self.dateUsernameList=[]
                            //                            self.dateNameList=[]
                            //                            for participant in json {
                            //                                self.dateUsernameList.append((participant["username"] as! String).base64Decoded()!)
                            //                                self.dateNameList.append((participant["display_name"] as! String).base64Decoded()!)
                            //                            }
                            //                            self.whoTableView.reloadData()
                            //                            self.whoHeight.constant = self.whoTableView.contentSize.height
                        } else {
                        }
                    }
                } catch _ as NSError {
                    
                }
            }
            self.table.reloadData()
            
        }
        
        
        

    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.delegate = self
        table.dataSource = self
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 130
        let image = UIImage(named: "325_little")!.withRenderingMode(.alwaysTemplate)
        let im = UIImageView(image: image)
        im.tintColor = .white
        im.contentMode = .scaleAspectFit
        self.navigationItem.titleView=im
        updateTable()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        let nav = self.navigationController
        let tab = nav?.viewControllers[0] as! MainTabController
        tab.selectedViewController?.viewWillAppear(true)
    }
    
    
}
