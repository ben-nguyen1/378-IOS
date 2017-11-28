//
//  TutorialImageViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 11/3/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class TutorialImageViewController: UIViewController {

    @IBOutlet weak var imageUI: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    var fileName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        super.viewDidLoad()
        self.imageUI.image = UIImage(named: fileName!)

        // Do any additional setup after loading the view.
        
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0;
        
        if (fileName == "1") {
            label.text = "Welcome! New accounts are directed to go through the tutorial. In the overview, you can see your budget, progress of some of your goals, and a checklist of some unpaid items."
        } else if (fileName == "2") {
            label.text = "This is where you will login. Enter your email address and your password to login into the app."
        } else if (fileName == "3") {
            label.text = "This is the budget screen. Here, you add your sources of income (first job, second job, etc.) as well as sources of expenses (rent, cable bill, etc.)"
        } else if (fileName == "4") {
            label.text = "The checklist screen lets you track what expenses you still need to pay off. Monthly expenses from the budget are also shown here. You can also add more expenses."
        } else if (fileName == "5") {
            label.text = "In the goals screen, you can add financial goals that you want to work towards. A progress bar is shown under each goal as well as a percentage to indicate completion. You can click on an existing goal to edit it."
        } else if (fileName == "6") {
            label.text = "Here, you can config an existing goal or fill out a new goal."
        }
        
    }
    @IBAction func exit(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarController = storyboard.instantiateViewController(withIdentifier: "TabBarVC") as! TabBarViewController
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = tabBarController
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.  //vsouza-awesome-ios
    }
}
