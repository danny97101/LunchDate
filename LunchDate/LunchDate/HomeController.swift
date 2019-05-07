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
    @IBOutlet weak var noFriendsLabel: UILabel!
    @IBOutlet weak var whenLabel: UILabel!
    @IBOutlet weak var whereLabel: UILabel!
    @IBOutlet weak var whoHeight: NSLayoutConstraint!
    @IBOutlet weak var whoTableView: UITableView!
    
    var dateNameList: [String] = []
    var dateUsernameList: [String] = []
    var dateActiveList: [Int] = []
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == dateTable {
            return goodNameList.count
        } else {
            return dateNameList.count
        }
    }
    @IBOutlet weak var pickDatesScrollView: UIScrollView!
    
    @IBOutlet weak var showDatesScrollView: UIScrollView!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == dateTable {
            let cell = tableView.dequeueReusableCell(withIdentifier: "date", for: indexPath) as! DateTableViewCell
            cell.nameLabel.text = goodNameList[indexPath.item]
            cell.usernameLabel.text = goodUsernameList[indexPath.item]
            cell.freeLabel.text = goodFreeList[indexPath.item]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath) as! FriendTableViewCell
            cell.nameLabel.text = dateNameList[indexPath.item]
            cell.usernameLabel.text = dateUsernameList[indexPath.item]
            cell.removeButton.isHidden = true
            if dateActiveList[indexPath.item] == 2 {
                cell.statusPic.image = UIImage(named: "logo-0")
            } else if dateActiveList[indexPath.item] == 1 {
                cell.statusPic.image = UIImage(named: "logo-1")
            } else {
                cell.statusPic.image = UIImage(named: "logo-2")
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == dateTable {
            let name = goodNameList[indexPath.item]
            let username = goodUsernameList[indexPath.item]
            
            selectedNames.append(name)
            selectedUserNames.append(username)
            
            let freeTime = goodFreeList[indexPath.item]
            let index = freeTime.index(freeTime.startIndex, offsetBy: 6)

            let freeTimes = freeTime.suffix(from:index).split(separator:",")
            var thisFreeList: [DateInterval] = []
            for time in freeTimes{
                let tup = time.split(separator: "-")
                let beg = tup[0]
                let end = tup[1]
                let begSplit = beg.components(separatedBy: CharacterSet.decimalDigits.inverted)
                let endSplit = end.components(separatedBy: CharacterSet.decimalDigits.inverted)
                var begHour = Int(begSplit[0])!
                if begHour < 11 {
                    begHour += 12
                }
                var endHour = Int(endSplit[0])!
                if endHour < 11 {
                    endHour += 12
                }
                let startDate = Date(timeIntervalSince1970: Double(3600*begHour + 60*Int(begSplit[1])!))
                let endDate = Date(timeIntervalSince1970: Double(3600*endHour + 60*Int(endSplit[1])!)-1)
                let freeInterval = DateInterval(start: startDate, end: endDate)
                thisFreeList.append(freeInterval)
            }
            selectedFree.append(thisFreeList)
            updateTable()
        }
    }
    
    var everybodyFree: [DateInterval] = []
    
    func updateTable() {
        
        if selectedNames.count == 0 {
            self.lunchButton.isHidden = true
//            self.goodNameList = nameList
//            self.goodUsernameList = usernameList
//            self.goodFreeList = freeList
//            self.dateTable.reloadData()
//            self.dateTableHeight.constant = self.dateTable.contentSize.height
//
//            return
        } else {
            self.lunchButton.isHidden = false
        }
        
        self.goodNameList = []
        self.goodUsernameList = []
        self.goodFreeList = []
        
        
        everybodyFree = [DateInterval(start: Date(timeIntervalSince1970: Double(3600*11)), end: Date(timeIntervalSince1970: Double(3600*14)))]
        
        var selectedPlusMe = selectedFree
        selectedPlusMe.append(meFree)
        for intList in selectedPlusMe {
            var newEverybodyFree: [DateInterval] = []

            for int in intList {
                for freeInt in everybodyFree {
                    if let intersection = freeInt.intersection(with: int) {
                        newEverybodyFree.append(intersection)
                    }
                }
            }
            everybodyFree = newEverybodyFree

        }
        
        for i in 0..<nameList.count {
            let name = nameList[i]
            let username = usernameList[i]
            
            let freeTime = freeList[i]
            let index = freeTime.index(freeTime.startIndex, offsetBy: 6)
            
            
            let freeTimes = freeTime.suffix(from:index).split(separator:",")
            var overlap = false
            for time in freeTimes{
                let tup = time.split(separator: "-")
                let beg = tup[0]
                let end = tup[1]
                let begSplit = beg.components(separatedBy: CharacterSet.decimalDigits.inverted)
                let endSplit = end.components(separatedBy: CharacterSet.decimalDigits.inverted)
                var begHour = Int(begSplit[0])!
                if begHour < 11 {
                    begHour += 12
                }
                var endHour = Int(endSplit[0])!
                if endHour < 11 {
                    endHour += 12
                }
                let startDate = Date(timeIntervalSince1970: Double(3600*begHour + 60*Int(begSplit[1])!))
                let endDate = Date(timeIntervalSince1970: Double(3600*endHour + 60*Int(endSplit[1])!)-1)
                let freeInterval = DateInterval(start: startDate, end: endDate)
                
                for int in everybodyFree {
                    if freeInterval.intersects(int) {
                        overlap = true
                        break
                    }
                }
            }
            
            if overlap {
                goodNameList.append(name)
                goodUsernameList.append(username)
                goodFreeList.append(freeTime)
            }
        }
        dateTable.reloadData()
        for i in 0..<goodUsernameList.count {
            if selectedUserNames.contains(goodUsernameList[i]) {
                self.dateTable.selectRow(at: IndexPath(row: i, section: 0), animated: true, scrollPosition: .bottom)
            }
        }
        self.dateTableHeight.constant = self.dateTable.contentSize.height

    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let username = goodUsernameList[indexPath.item]
        let index = selectedUserNames.firstIndex(of: username)
        selectedUserNames.remove(at: index!)
        selectedNames.remove(at: index!)
        selectedFree.remove(at: index!)
        updateTable()
    }
    
    var selectedUserNames: [String] = []
    var selectedNames: [String] = []
    var selectedFree: [[DateInterval]] = []
    
    var nameList: [String] = []
    var usernameList: [String] = []
    var freeList: [String] = []
    
    var goodNameList: [String] = []
    var goodUsernameList: [String] = []
    var goodFreeList: [String] = []
    
    var meFree: [DateInterval] = []

    
    @IBOutlet weak var dateTable: UITableView!
    @IBOutlet weak var dateTableHeight: NSLayoutConstraint!
    @IBOutlet weak var lunchButton: UIButton!
    
    @IBAction func letsLunch(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let invitationController = storyBoard.instantiateViewController(withIdentifier: "pls") as! InvitationController
        invitationController.usernames = selectedUserNames
        invitationController.names = selectedNames
        invitationController.free = selectedFree
        invitationController.everybodyFree = everybodyFree
        self.navigationController!.show(invitationController, sender: self)
    }
    
    func loadDate() {
        print("jsdkls")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lunchButton.isHidden = true
        pickDatesScrollView.isHidden = true
        showDatesScrollView.isHidden = true
        
        dateTable.delegate = self
        dateTable.dataSource = self
        dateTable.allowsMultipleSelection = true
        dateTable.allowsMultipleSelectionDuringEditing = true
        
        whoTableView.delegate = self
        whoTableView.dataSource = self
        
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
        
        do {
            
        var events: [EKEvent]? = nil
        if let aPredicate = predicate {
            events = store.events(matching: aPredicate)
            if let aEvents = events {
                let dateFormatter = DateFormatter()
                var uploadString = ""
                dateFormatter.dateFormat = "HH:mm"
  
                let todayAt11 = day
                let todayAt2 = end

                
                if (aEvents.count > 0 && (aEvents[0].startDate)! > todayAt11!) || aEvents.count==0 {
                    uploadString += "11:00-"
                }
                var startDate: String? = nil
                var endDate: String? = nil
                for event in aEvents {
                    startDate = dateFormatter.string(from: event.startDate)
                    endDate = dateFormatter.string(from: event.endDate)
                    if (event.startDate)! > todayAt11! {
                        uploadString +=  startDate!
                        if (event.endDate)! < todayAt2! {
                            uploadString += ","
                        }
                    }
                    if (event.endDate)! < todayAt2! {
                        uploadString += endDate! + "-"
                    }
                }
                if (endDate != nil && endDate != "14:00") || aEvents.count==0{
                    uploadString += "14:00"
                }
                let freeTimes = uploadString.split(separator:",")
                var thisFreeList: [DateInterval] = []
                for time in freeTimes{
                    let tup = time.split(separator: "-")
                    let beg = tup[0]
                    let end = tup[1]
                    let begSplit = beg.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    let endSplit = end.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    var begHour = Int(begSplit[0])!
                    if begHour < 11 {
                        begHour += 12
                    }
                    var endHour = Int(endSplit[0])!
                    if endHour < 11 {
                        endHour += 12
                    }
                    let startDate = Date(timeIntervalSince1970: Double(3600*begHour + 60*Int(begSplit[1])!))
                    let endDate = Date(timeIntervalSince1970: Double(3600*endHour + 60*Int(endSplit[1])!)-1)
                    let freeInterval = DateInterval(start: startDate, end: endDate)
                    thisFreeList.append(freeInterval)
                }
                meFree = thisFreeList
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
        } catch _ as NSException {
            print("no calendar bitch")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("APPEARING")
        
        //TODO: CHECK IF THEY HAVE A DATE
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        
        let parameters: Parameters = [
            "action": "getCurrentDate",
            "token": token!
        ]
        
        Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            //            let tab = self.navigationController?.viewControllers[0] as! MainTabController
            //            let home = tab.selectedViewController as! HomeController
            //            home.loadDate()
            if let data = response.data, let responseString =  String(data: data, encoding: .utf8){
                print(responseString)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                        if json.count > 0 {
                            self.pickDatesScrollView.isHidden = true
                            self.showDatesScrollView.isHidden = false
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
                            
                            self.whenLabel.text = dayStr + betterFormatter.string(from: date!)
                            self.whereLabel.text = json[0]["dining_hall"] as? String
                            self.dateUsernameList=[]
                            self.dateNameList=[]
                            self.dateActiveList = []
                            for participant in json {
                                self.dateUsernameList.append((participant["username"] as! String).base64Decoded()!)
                                self.dateNameList.append((participant["display_name"] as! String).base64Decoded()!)
                                self.dateActiveList.append(participant["active"] as! Int)
                            }
                            self.whoTableView.reloadData()
                            self.whoHeight.constant = self.whoTableView.contentSize.height
                        } else {
                            self.pickDatesScrollView.isHidden = false
                            self.showDatesScrollView.isHidden = true
                        }
                    }
                } catch _ as NSError {
                    
                }
            }
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        selectedFree = []
        selectedNames = []
        selectedUserNames = []
        updateTable()

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
                            
                            self.goodNameList = self.nameList
                            self.goodUsernameList = self.usernameList
                            self.goodFreeList = self.freeList
                            self.updateTable()
                            
                            if json.count == 0 {
                                self.noFriendsLabel.isHidden = false
//                                self.friendTableViewHeight.constant = 129
                                self.dateTableHeight.constant = 129
                            } else {
                                self.noFriendsLabel.isHidden = true
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

