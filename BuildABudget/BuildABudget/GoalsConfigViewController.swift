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
    @IBOutlet weak var goalsTargetTextField: UITextField!
    
    @IBAction func targetDatePicket(_ sender: UIDatePicker) {
    }
    
    @IBOutlet weak var monthlyContributionAmountLabel: UILabel!
    
    
    @IBAction func monthlyContributionSlider(_ sender: UISlider) {
    }
    
    @IBOutlet weak var estimatedCompletionDateLabel: UILabel!
    @IBOutlet weak var progressPercentLabel: UILabel!
    @IBOutlet weak var goalProgressbar: UIProgressView!
    @IBOutlet weak var amountRemainingLabel: UILabel!
    
    
    @IBAction func saveGoalButton(_ sender: Any) {
        
        //if all fields are filled out && no errors -> save MyGoal
        
        //return to GoalsVC and trigger the reload of the goasTable
    }
    
    @IBAction func deleteGoalButton(_ sender: Any) {
        
        //if this button is clicked show a pop UIAlert asking for confirmation to delete
        
        //if delete if confirmed -> remove this goal from coreData
        
        //return to GoalsVC and trigger the reload of the goalsTable.
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.goalMonthlyContributionTextField.keyboardType = UIKeyboardType.decimalPad
        //self.goalTargetDateTextField.keyboardType = UIKeyboardType.decimalPad
        //self.goalMonthlyContributionTextField.keyboardType = UIKeyboardType.decimalPad
        //self.goalsTargetAmountTextField.keyboardType = UIKeyboardType.decimalPad
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}













