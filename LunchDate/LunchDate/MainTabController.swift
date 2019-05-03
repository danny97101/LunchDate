//
//  MainTabController.swift
//  LunchDate
//
//  Created by Danny Akimchuk on 4/21/19.
//  Copyright © 2019 LunchDateTeam. All rights reserved.
//

import UIKit

class MainTabController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let image = UIImage(named: "325_little")!.withRenderingMode(.alwaysTemplate)
        let im = UIImageView(image: image)
        im.tintColor = .white
        im.contentMode = .scaleAspectFit
        self.navigationItem.titleView=im
    }
}
