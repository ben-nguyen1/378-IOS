//
//  SettingsViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 11/27/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func tutorial(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Tutorial", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "tutorialPageVC") as! TutorialPageViewController
        present(vc, animated: true, completion: nil)
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
