//
//  OverViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 10/20/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class OverViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("in overview")
        // Do any additional setup after loading the view.
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.title = "Overview"
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
