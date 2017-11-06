//
//  GoalsConfigViewController.swift
//  BuildABudget
//
//  Created by chris on 11/4/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//

import UIKit

class GoalsConfigViewController: UIViewController {

    
    @IBOutlet weak var goalNameTextField: UITextField!
    
   
    @IBOutlet weak var goalTargetDateTextField: UITextField!
    
    
    @IBOutlet weak var goalMonthlyContributionTextField: UITextField!
    
    
    @IBOutlet weak var goalsTargetAmountTextField: UITextField!
    
    
    @IBOutlet weak var goalSaveButton: UIButton!
    
    
    @IBOutlet weak var estimatedCompletionDateLabel: UILabel!
    
    
    @IBOutlet weak var progressHasLabel: UILabel!
    
    
    @IBOutlet weak var progressTargetLabel: UILabel!
    
    
    @IBOutlet weak var amountRemainingLabel: UILabel!
    
    
    @IBOutlet weak var goalsDeleteButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
