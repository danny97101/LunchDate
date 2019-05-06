//
//  InvitationController.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 5/6/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class InvitationController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource, UITextViewDelegate, UIScrollViewDelegate {
    @IBOutlet weak var messageView: UITextView!
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerOptions.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerOptions[row]
    }
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var whoTableHeight: NSLayoutConstraint!
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath) as! FriendTableViewCell
            cell.nameLabel.text = names[indexPath.item]
            cell.usernameLabel.text = usernames[indexPath.item]
            cell.removeButton.isHidden = true
            return cell
    }
    
    @IBOutlet weak var locationPicker: UIPickerView!
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            //scrollView.contentInset = .zero
            scrollHeight.constant = 0
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)

            scrollView.scrollToTop()
        } else {
//            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            scrollHeight.constant = -keyboardViewEndFrame.height
            scrollView.contentSize = CGSize(width: scrollView.frame.width, height: scrollView.frame.height)
//            let bottomOffset = CGPoint(x: 0, y: -(self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom));
//            scrollView.setContentOffset(bottomOffset, animated: true)
            scrollView.scrollToBottom()
        }
        
//        scrollView.scrollIndicatorInsets = scrollView.contentInset
//        scrollView.scrollRectToVisible(textView.frame, animated: true)
    }
    var usernames: [String] = []
    var names: [String] = []
    var free: [[DateInterval]] = []
    var everybodyFree: [DateInterval] = []
    var diningHallOptions: [Set<String>] = []
    
    var pickerOptions: [String] = []
//
//    override func dismissKeyboard() {
//        super.dismissKeyboard()
//        //let bottomOffset = CGPoint(x: 0, y: 0);
//        //scrollView.setContentOffset(bottomOffset, animated: true)
//        scrollHeight.constant = 0
//
//        scrollView.scrollToTop()
//
//    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter your message!"
            textView.textColor = UIColor.lightGray
        }
    }
    
    @IBOutlet weak var whoTable: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let image = UIImage(named: "325_little")!.withRenderingMode(.alwaysTemplate)
        let im = UIImageView(image: image)
        im.tintColor = .white
        im.contentMode = .scaleAspectFit
        self.navigationItem.titleView=im
        
        whoTable.delegate = self
        whoTable.dataSource = self
        locationPicker.delegate = self
        locationPicker.dataSource = self
        messageView.delegate = self
        scrollView.delegate = self
        messageView.text = "Enter your message!"
        messageView.textColor = UIColor.lightGray
        whoTable.reloadData()
        whoTableHeight.constant = whoTable.contentSize.height
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        scrollView.keyboardDismissMode = .interactive
        
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        var usersPlusMe = usernames
        usersPlusMe.append(defaults.string(forKey: "username")!)
        for user in usersPlusMe {
            let parameters: Parameters = [
                "action" : "getPotentialLocations",
                "token" : token!,
                "username": user
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
                        print(user)
                        print(responseString)
                        do {
                            if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                                var options: Set<String> = []
                                for option in json {
                                    let diningHall = option["dining_hall"] as! String
                                    options.insert(diningHall)
                                }
                                self.diningHallOptions.append(options)
                                if self.diningHallOptions.count == usersPlusMe.count {
                                    self.getIntersection()
                                }
                            }
                        } catch _ as NSError {
                            
                        }
                    }
                }
            }
        }
        
    }
    
    func getIntersection() {
        var intersect = diningHallOptions[0]
        for user in diningHallOptions {
            intersect = intersect.intersection(user)
        }
        self.pickerOptions = Array(intersect)
        self.locationPicker.reloadAllComponents()
    }
}


extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension UIScrollView {
    func scrollToTop() {
        let desiredOffset = CGPoint(x: 0, y: -contentInset.top)
        setContentOffset(desiredOffset, animated: true)
    }
    
    func scrollToBottom() {
        let contentOffset = CGPoint(x: 0, y: contentSize.height - bounds.size.height)
        self.setContentOffset(contentOffset, animated: true)
    }
    
    
}
