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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
