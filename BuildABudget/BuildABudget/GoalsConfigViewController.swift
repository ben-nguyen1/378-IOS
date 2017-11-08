//
//  GoalsConfigViewController.swift
//  BuildABudget
//
//  Created by chris on 11/4/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//

import UIKit

class GoalsConfigViewController: UIViewController {

    var thisGoal:MyGoal? = nil //must be var because this could be overwritten by a cell seque.
    let thisDate = MyDate.dateConverter
    
    var name:String = ""
    var targetAmount: Double = 0.0
    var targetDate: Date? = nil
    var monthlyContribution: Double = 0.0
    //var contributionList: [MyTransaction] = []
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var targetAmountTextField: UITextField!
    @IBOutlet weak var targetDateTextField: UILabel!
    @IBOutlet weak var monthlyContributionTextField: UITextField!
    
    
    @IBOutlet weak var estimatedCompletionDateLabel: UILabel!
    @IBOutlet weak var progressPercentLabel: UILabel!
    @IBOutlet weak var goalProgressbar: UIProgressView!
    @IBOutlet weak var amountRemainingLabel: UILabel!
    
    
    @IBAction func saveGoalButton(_ sender: Any) {
        
        thisGoal?.desciption = nameTextField.text!
        thisGoal?.startDate = Date()//this is the current date
        thisGoal?.targetDate = thisDate.stringToDate(inputString: targetDateTextField.text!)
        thisGoal?.monthlyContribution = Double(monthlyContributionTextField.text!)!
        thisGoal?.targetAmount = Double(targetAmountTextField.text!)!
         
    }
    
    @IBAction func deleteGoalButton(_ sender: Any) {
        
        //if this button is clicked show a pop UIAlert asking for confirmation to delete
        
        //if delete if confirmed -> remove this goal from coreData
        
        //return to GoalsVC and trigger the reload of the goalsTable.
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

    
    
    
}













