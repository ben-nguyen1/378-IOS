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
    
    var isNewGoal = true //value is only changed when the GoalsCell segue sets this to false to indicate thisGoal is an existing MyGoal
    
    
    /*
    //if an existing MyGoal was passes into this ViewController these values will be overwritten to the existing values.
    var name:String = ""
    var targetAmount: Double = -1.0
    var targetDate: Date? = nil
    var monthlyContribution: Double = -1.0
    var contributionList: [MyTransaction] = [] //this is expected to be empty for new transactions
    
    
    //original values of MyGoal object passes in from GoalsCell
    let originalName:String = ""
    let originalTargetAmount: Double = 0.0
    let originalTargetDate: Date? = nil
    let originalMonthlyContribution: Double = 0.0
    */
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var targetAmountTextField: UITextField!
    @IBOutlet weak var targetDateTextField: UILabel!
    @IBOutlet weak var monthlyContributionTextField: UITextField!
    
    
    @IBOutlet weak var estimatedCompletionDateLabel: UILabel!
    @IBOutlet weak var progressPercentLabel: UILabel!
    @IBOutlet weak var goalProgressbar: UIProgressView!
    @IBOutlet weak var amountRemainingLabel: UILabel!
    
    
    @IBAction func saveGoalButton(_ sender: Any) {
        
        if isNewGoal == true && allFieldsFilledOut() {
            thisGoal?.desciption = nameTextField.text!
            thisGoal?.startDate = Date()//this is the current date
            thisGoal?.targetDate = thisDate.stringToDate(inputString: targetDateTextField.text!)
            thisGoal?.monthlyContribution = Double(monthlyContributionTextField.text!)!
            thisGoal?.targetAmount = Double(targetAmountTextField.text!)!
            thisGoal?.allContributions = []
            
            thisGoal = MyGoal.create(iDescription: nameTextField.text!,
                                     iStartDate: Date(),
                                     iTargetDate: thisDate.stringToDate(inputString: targetDateTextField.text!),
                                     iMonthlyContribution: Double(monthlyContributionTextField.text!)!,
                                     iTargetAmount: Double(targetAmountTextField.text!)!,
                                     iContributionList: [])
            
            thisGoal?.saveMyGoal(inputGoal: thisGoal!)//pass this newly constructed MyGoal object to MyGoal class to be saved
        }
        else if isNewGoal == false && allFieldsFilledOut() && existingMyGoalValuesChangedByUser() {
            //if isNewGoal == false -> this is the case of a existing MyGoal being resaved after one/many of its values were changed
            thisGoal?.desciption = nameTextField.text!
            thisGoal?.startDate = Date()//this is the current date
            thisGoal?.targetDate = thisDate.stringToDate(inputString: targetDateTextField.text!)
            thisGoal?.monthlyContribution = Double(monthlyContributionTextField.text!)!
            thisGoal?.targetAmount = Double(targetAmountTextField.text!)!
        }
        else {
            print("ERROR: no goals Saved")//error
        }
    }
    
    @IBAction func deleteGoalButton(_ sender: Any) {
        
        //if this button is clicked show a pop UIAlert asking for confirmation to delete
        
        //if delete if confirmed -> remove this goal from coreData
        
        //return to GoalsVC and trigger the reload of the goalsTable.
    }
    
    func allFieldsFilledOut() -> Bool{
        
        if ( nameTextField.text!.isEmpty ||
             targetDateTextField.text!.isEmpty ||
             monthlyContributionTextField.text!.isEmpty ||
             targetAmountTextField.text!.isEmpty){
                print("ERROR: not all fields are filled out")
                return false
        }
        else {
            return true
        }
    }
    
    //only called when isNewGoal == false <- this func evaluates if the existing MyGoal object values are the same as those the user filled out
    func existingMyGoalValuesChangedByUser() -> Bool{
        
        //if the user either did not change any field or did so only to change the value of the changed field back to the original value
        if (thisGoal?.desciption == nameTextField.text! &&
            thisGoal?.targetDate == thisDate.stringToDate(inputString: targetDateTextField.text!) &&
            thisGoal?.monthlyContribution == Double(monthlyContributionTextField.text!)! &&
            thisGoal?.targetAmount == Double(targetAmountTextField.text!)!) {
            return false
        }
        else {
            return true //the user must have changed one field from the existing value
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    

    
    
    
}













