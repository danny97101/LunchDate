//
//  MainTabController.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 4/21/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit
import Alamofire

class MainTabController: UITabBarController, UITabBarControllerDelegate {
    @IBOutlet weak var bell: UIBarButtonItem!
    @IBAction func clickedBell(_ sender: Any) {
        let storyBoard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let notificationController = storyBoard.instantiateViewController(withIdentifier: "notif") as! NotificationController
        self.navigationController!.show(notificationController, sender: self)
    }
    
    var startIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //selectedIndex = startIndex
        // Do any additional setup after loading the view.
        let image = UIImage(named: "325_little")!.withRenderingMode(.alwaysTemplate)
        let im = UIImageView(image: image)
        im.tintColor = .white
        im.contentMode = .scaleAspectFit
        self.navigationItem.titleView=im
        self.delegate = self
        
//        for viewController in viewControllers! {
//            viewController.viewWillAppear(true)
//        }
        
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
            
            if let data = response.data, let responseString =  String(data: data, encoding: .utf8){
                print(responseString)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                        if json.count > 0 {
                            self.bell.addBadge("!", withOffset: CGPoint(x: 10, y: 0))
                        } else {
                            self.bell.removeBadge()
                        }
                    }
                } catch _ as NSError {
                    
                }
            }
        }
        
    }
    
    // UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        
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
            
            if let data = response.data, let responseString =  String(data: data, encoding: .utf8){
                print(responseString)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                        if json.count > 0 {
                            self.bell.addBadge("!", withOffset: CGPoint(x: 10, y: 0))
                        } else {
                            self.bell.removeBadge()
                        }
                    }
                } catch _ as NSError {
                    
                }
            }
        }
        
        
        
        
        
        if let controller = viewController as? SearchController {
            controller.searchController = UISearchController(searchResultsController: nil)
            controller.searchController.searchResultsUpdater = controller
            controller.searchController.obscuresBackgroundDuringPresentation = false
            controller.searchController.searchBar.placeholder = "Search Users"
            //controller.searchController.searchBar.tintColor = UIColor(red: 225, green: 81, blue: 74)
            
            controller.searchController.searchBar.tintColor = .white
            UITextField.appearance(whenContainedInInstancesOf: [type(of: controller.searchController.searchBar)]).tintColor = UIColor(red: 225, green: 81, blue: 74)
            
            
            controller.searchController.hidesNavigationBarDuringPresentation = false
            controller.definesPresentationContext = true
            controller.searchTable.delegate = controller
            controller.searchTable.dataSource = controller
            self.navigationItem.titleView = controller.searchController.searchBar
            self.navigationItem.titleView?.becomeFirstResponder()
        } else {
            
            if let controller = self.viewControllers?[1] as? SearchController {
                controller.searchController.isActive = false

            }
            
            let image = UIImage(named: "325_little")!.withRenderingMode(.alwaysTemplate)
            let im = UIImageView(image: image)
            im.tintColor = .white
            im.contentMode = .scaleAspectFit
            self.navigationItem.titleView=im
        }
    }
    override func viewWillAppear(_ animated: Bool) {
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
            
            if let data = response.data, let responseString =  String(data: data, encoding: .utf8){
                print(responseString)
                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [[String : Any]] {
                        if json.count > 0 {
                            self.bell.addBadge("!", withOffset: CGPoint(x: 10, y: 0))
                        } else {
                            self.bell.removeBadge()
                        }
                    }
                } catch _ as NSError {
                    
                }
            }
        }
    }
    
    
}


extension CAShapeLayer {
    func drawCircleAtLocation(location: CGPoint, withRadius radius: CGFloat, andColor color: UIColor, filled: Bool) {
        fillColor = filled ? color.cgColor : UIColor.white.cgColor
        strokeColor = color.cgColor
        let origin = CGPoint(x: location.x - radius, y: location.y - radius)
        path = UIBezierPath(ovalIn: CGRect(origin: origin, size: CGSize(width: radius * 2, height: radius * 2))).cgPath
    }
}

private var handle: UInt8 = 0

extension UIBarButtonItem {
    private var badgeLayer: CAShapeLayer? {
        if let b: AnyObject = objc_getAssociatedObject(self, &handle) as AnyObject? {
            return b as? CAShapeLayer
        } else {
            return nil
        }
    }
    
    func addBadge(_ string: String, withOffset offset: CGPoint = CGPoint.zero, andColor color: UIColor = UIColor.white, andFilled filled: Bool = true) {
        guard let view = self.value(forKey: "view") as? UIView else { return }
        
        badgeLayer?.removeFromSuperlayer()
        
        // Initialize Badge
        let badge = CAShapeLayer()
        let radius = CGFloat(7)
        let location = CGPoint(x: view.frame.width - (radius + offset.x), y: (radius + offset.y))
        badge.drawCircleAtLocation(location: location, withRadius: radius, andColor: color, filled: filled)
        view.layer.addSublayer(badge)
        
        // Initialiaze Badge's label
        let label = CATextLayer()
        label.string = string
        label.alignmentMode = CATextLayerAlignmentMode.center
        label.fontSize = 11
        label.frame = CGRect(origin: CGPoint(x: location.x - 4, y: offset.y), size: CGSize(width: 8, height: 16))
        label.foregroundColor = filled ? UIColor(red: 225, green: 81, blue: 74).cgColor : color.cgColor
        label.backgroundColor = UIColor.clear.cgColor
        label.contentsScale = UIScreen.main.scale
        badge.addSublayer(label)
        
        // Save Badge as UIBarButtonItem property
        objc_setAssociatedObject(self, &handle, badge, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    func updateBadge(_ string: String) {
        if let text = badgeLayer?.sublayers?.filter({ $0 is CATextLayer }).first as? CATextLayer {
            text.string = string
        }
    }
    
    func removeBadge() {
        badgeLayer?.removeFromSuperlayer()
    }
}
