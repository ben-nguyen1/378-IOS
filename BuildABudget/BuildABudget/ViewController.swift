//
//  ViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 10/6/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var login: UIButton!
    @IBOutlet weak var register: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        login.layer.cornerRadius = 5
        register.layer.cornerRadius = 5
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

