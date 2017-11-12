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
            label.text = "Welcome to the tutorial!. When you first login, you will first see the overview screen. Here, you can see an overview of your budget, progress of some of your goals, and a checklist of unpaid items."
        } else if (fileName == "2") {
            label.text = "This is where you will login. Enter your email address and your password to login into the app"
        } else if (fileName == "3") {
            label.text = "This is the budget screen. Here, you add your sources of income (first job, second job, etc.) as well as sources of expenses (rent, cable bill, etc.)"
        } else if (fileName == "4") {
            label.text = "This is the budget screen. Here, you add your sources of income (first job, second job, etc.) as well as sources of expenses (rent, cable bill, etc.)"
        } else if (fileName == "5") {
            label.text = "This is the budget screen. Here, you add your sources of income (first job, second job, etc.) as well as sources of expenses (rent, cable bill, etc.)"
        } else if (fileName == "6") {
            label.text = "This is the budget screen. Here, you add your sources of income (first job, second job, etc.) as well as sources of expenses (rent, cable bill, etc.)"
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.  //vsouza-awesome-ios
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
