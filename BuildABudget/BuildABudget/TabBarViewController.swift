//
//  TabBarViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 10/20/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
import UIKit

class TabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("in tabbar")
        self.selectedIndex = 0
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
