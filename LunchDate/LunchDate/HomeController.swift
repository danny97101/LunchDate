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

class HomeController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
                if aEvents.count > 0 && dateFormatter.string(from: aEvents[0].startDate) != "11:00" {
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

}

