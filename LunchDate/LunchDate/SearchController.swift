//
//  SearchController.swift
//  LunchDate
//
//  Created by Timothy Marotta on 4/29/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit
import Alamofire

class SearchController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return usernames.count
    }
    @IBOutlet var bigView: UIView!
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friend", for: indexPath) as! FriendTableViewCell
        cell.nameLabel.text = names[indexPath.item]
        cell.usernameLabel.text = usernames[indexPath.item]
        cell.removeButton.backgroundColor = UIColor(red: 144, green: 218, blue: 130)
        cell.removeButton.setTitle("Add", for: .normal)
        return cell
    }
    
    @IBOutlet weak var searchTable: UITableView!
    var usernames: [String] = []
    var names: [String] = []
    
    var searchController = UISearchController(searchResultsController: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //view.addSubview(searchController.searchBar)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bigView.layoutIfNeeded()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        searchController.searchBar.text = ""
//        updateSearchResults(for: searchController)
        //parent!.navigationItem.titleView?.willRemoveSubview(searchController.searchBar)


    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        let defaults = UserDefaults.standard
        let token = defaults.string(forKey: "token")
        let parameters: Parameters = [
            "action": "searchUsers",
            "token": token!,
            "search": searchText
        ]
        
        Alamofire.request(Config.host + "action.php", method: .post, parameters: parameters, encoding: URLEncoding.default).responseJSON { response in
            //            let tab = self.navigationController?.viewControllers[0] as! MainTabController
            //            let home = tab.selectedViewController as! HomeController
            //            home.loadDate()
            if let data = response.data, let responseString =  String(data: data, encoding: .utf8){
                print(responseString)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                        self.names = []
                        self.usernames = []
                        for user in json {
                            self.names.append((user["display_name"] as! String).base64Decoded()!)
                            self.usernames.append((user["username"] as! String).base64Decoded()!)
                        }
                        self.searchTable.reloadData()
                    }
                } catch _ as NSError {
                    
                }
            }
        }
    }
    
}


extension SearchController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        if searchBarIsEmpty() {
            names = []
            usernames = []
            searchTable.reloadData()
        } else {
            filterContentForSearchText(searchController.searchBar.text!)
        }
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}
