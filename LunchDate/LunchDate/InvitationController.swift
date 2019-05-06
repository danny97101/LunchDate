//
//  InvitationController.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 5/6/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import Foundation
import UIKit

class InvitationController: UIViewController, UITableViewDelegate, UITableViewDataSource {
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
    
    @IBOutlet weak var scrollHeight: NSLayoutConstraint!
    @IBOutlet weak var textView: UITextView!
    @objc func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardScreenEndFrame = keyboardValue.cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            //scrollView.contentInset = .zero
            scrollHeight.constant = 0
            scrollView.scrollToTop()
        } else {
//            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height - view.safeAreaInsets.bottom, right: 0)
            scrollHeight.constant = -keyboardViewEndFrame.height
            let bottomOffset = CGPoint(x: 0, y: -(self.scrollView.contentSize.height - self.scrollView.bounds.size.height + self.scrollView.contentInset.bottom));
            scrollView.setContentOffset(bottomOffset, animated: true)

        }
        
//        scrollView.scrollIndicatorInsets = scrollView.contentInset
//        scrollView.scrollRectToVisible(textView.frame, animated: true)
    }
    var usernames: [String] = []
    var names: [String] = []
    var free: [[DateInterval]] = []
    var everybodyFree: [DateInterval] = []
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
        whoTable.reloadData()
        whoTableHeight.constant = whoTable.contentSize.height
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        scrollView.keyboardDismissMode = .interactive
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
    
    
}
