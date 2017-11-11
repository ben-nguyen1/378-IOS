//
//  GoalsConfigViewController.swift
//  BuildABudget
//
//  Created by chris on 11/4/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//

import UIKit

protocol EditGoalDelegate {
    
    func isUniqueGoalName( inputNameString: String ) -> Bool
    
    //func deleteThisGoal( inputGoal: MyGoal ) -> Bool
}

protocol ValidDateDelegate {
    
    func isValidDate(inputDateString: String) -> Bool
}





class GoalsConfigViewController: UIViewController {

    var validGoalDelegate: EditGoalDelegate!
    var thisGoal:MyGoal? = nil //must be var because this could be overwritten by a cell seque.
    let thisDate = MyDate.dateConverter //gives us access to the MyDate methods
    var isNewGoal = true //value is only changed when the GoalsCell segue sets this to false to indicate thisGoal is an existing MyGoal
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var targetAmountTextField: UITextField!
    @IBOutlet weak var targetDateTextField: UITextField!
    @IBOutlet weak var monthlyContributionTextField: UITextField!
    
    @IBOutlet weak var estimatedCompletionDateLabel: UILabel!
    @IBOutlet weak var progressPercentLabel: UILabel!
    @IBOutlet weak var goalProgressbar: UIProgressView!
    @IBOutlet weak var amountRemainingLabel: UILabel!
    
    
    
    @IBAction func cancelButton(_ sender: Any) {} //do nothing and return to GoalsVC screen
    @IBAction func saveGoalButton(_ sender: Any) {
        
        if isNewGoal == true && allFieldsFilledOut() {
            
            //grab all the data from the alert window's text fields -> we are bringing them in as string first and checking that the input is valid
            guard let newNameString                 = self.nameTextField?.text                else { return }
            guard let newMonthlyContributionString  = self.monthlyContributionTextField?.text else { return }
            guard let newTargetDateString           = self.targetDateTextField?.text          else { return }
            guard let newTargetAmountString         = self.targetAmountTextField?.text        else { return }
            
            //thisDate.stringToDate(inputString: (self.targetDateTextField?.text)!)
            
            /*
            thisGoal?.desciption = nameTextField.text!
            thisGoal?.startDate = Date()//this is the current date
            thisGoal?.targetDate = thisDate.stringToDate(inputString: targetDateTextField.text!)
            thisGoal?.monthlyContribution = Double(monthlyContributionTextField.text!)!
            thisGoal?.targetAmount = Double(targetAmountTextField.text!)!
            thisGoal?.allContributions = []
            */
            
            thisGoal = MyGoal.create( iContributionList:    [],
                                      iDescription:         newNameString,
                                      iMonthlyContribution: Double(newMonthlyContributionString)!,
                                      iStartDate:           Date(),
                                      iTargetDate:          thisDate.stringToDate(inputString: newTargetDateString),
                                      iTargetAmount:        Double(newTargetAmountString)! )
            
            thisGoal?.saveMyGoal(inputGoal: thisGoal!)//pass this newly constructed MyGoal object to MyGoal class to be saved
            
            
            
        }
        else if isNewGoal == false && allFieldsFilledOut() && existingMyGoalValuesChangedByUser() { //DEBUG NEEDED WITH THIS PART OF THE METHOD, IT IS NOT UPDATING OLD RECORDS

            guard let newNameString                 = self.nameTextField?.text                else { return }
            guard let newMonthlyContributionString  = self.monthlyContributionTextField?.text else { return }
            guard let newTargetDateString           = self.targetDateTextField?.text          else { return }
            guard let newTargetAmountString         = self.targetAmountTextField?.text        else { return }
            
            thisGoal?.desciption            = newNameString
            thisGoal?.monthlyContribution   = Double(newMonthlyContributionString)!
            thisGoal?.targetDate            = thisDate.stringToDate(inputString: newTargetDateString)
            thisGoal?.targetAmount          = Double(newTargetAmountString)!
            
            thisGoal?.saveMyGoal(inputGoal: thisGoal!)
        }
        else {
            print("ERROR: no goals Saved")//error
        }
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
    
    //functions that check if user input is not an empty string and that it is a unique MyGoal description
    func checkGoalName( inputName:String) -> Bool{
        if  !inputName.isEmpty && validGoalDelegate.isUniqueGoalName( inputNameString: inputName) {
            return true
        }
        else {
            return false
        }
    }
    
    //checks if the goal does exist in the GoalsVC goalsList
    func isExistingGoal() -> Bool {
        
        if validGoalDelegate.isUniqueGoalName( inputNameString: (self.thisGoal?.desciption)! ){
            return true
        }
        else {
            return false
        }
    }
    
    
    
    
    //Displays UIDatePicker upon text field selection.
    func showGoalsDatePickerKeyboard(textField: UITextField) {
        if textField == targetDateTextField {//set the text field that should display the UIDatePicker
            let myDatePicker = UIDatePicker()
            myDatePicker.datePickerMode = .date
            myDatePicker.minimumDate = Date()
            textField.inputView = myDatePicker
            myDatePicker.addTarget(self, action: #selector(setSelectedDate(sender: )), for: .valueChanged) //this sends the currently selected date at every instance that user pauses to the setSelectedDate(sender: UIDatePicker) method
        }
    }
    
    //this func sets each input passed to it to a string and sets the dueDateTextField to the resulting string
    func setSelectedDate(sender: UIDatePicker) {
        targetDateTextField?.text = thisDate.dateToString(inputDate: (sender.date))
    }
    
    /*
    //Display UIAlert to confirm user want to delete this goal
    func launchConfirmDeleteWindow() {
        
        print(">>>GOALSCONFIGVC: launched delete confirmation window")
        //set the AlertWindow's title and instruction message to user
        let newDeleteConfirmation = UIAlertController(title: "Delete Confirmation", message: "Are you sure?", preferredStyle: .alert)
    
        let deleteAction = UIAlertAction(title: "Delete", style: .default) {
            (action: UIAlertAction!) -> Void in
            //call delete method -> this will delete the Goal and return to GoalsVC
            print("------before delete action AccessService totalGoals() = \(AccessService.access.totalGoals())")
            self.thisGoal?.deleteMyGoal(inputGoal: self.thisGoal!)
            
            print("!!!---DELETED thisGoal---!!!")
            print("------After  delete action AccessService totalGoals() = \(AccessService.access.totalGoals())")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
            //Dismisses UIAlertWindow -> no other action needs to be taken
        }
        
        //add the buttons to the Alert window
        newDeleteConfirmation.addAction(deleteAction)
        newDeleteConfirmation.addAction(cancelAction)
    
        //display the alert window on the screen
        present(newDeleteConfirmation, animated: true, completion: nil)
    }
    */
    
    
    
    
    //Required ViewController functions below:
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n>>>REACHED GOALSCONFIGVC")
        //set keyboard types
        //nameTextField -> will use the default keyboard (no need to set this)
        self.targetAmountTextField.keyboardType = UIKeyboardType.decimalPad
        self.monthlyContributionTextField.keyboardType = UIKeyboardType.decimalPad
        showGoalsDatePickerKeyboard(textField: self.targetDateTextField)
        
        //
        print("---> this goal == \(thisGoal)")
        if self.thisGoal != nil{
            //setup all UITextfields
            self.nameTextField.text                 = self.thisGoal?.desciption
            self.targetAmountTextField.text         = "\((self.thisGoal?.targetAmount)!)"//String(describing: self.thisGoal?.targetAmount)
            let tempDateToString:String = thisDate.dateToString(inputDate: (self.thisGoal?.targetDate)!)
            self.targetDateTextField.text           = tempDateToString
            self.monthlyContributionTextField.text  = "\(((self.thisGoal?.monthlyContribution))!)"
            
            //setup all UILabels
            self.estimatedCompletionDateLabel.text  = thisDate.dateToString(inputDate: (thisGoal?.getEstimatedCompletionDate())!)
            self.progressPercentLabel.text          = String( describing: (thisGoal?.getProgress())! )
            self.amountRemainingLabel.text          = String(describing: (thisGoal?.getRemainingAmount())! )
            
            
            print("thisGoal = \(self.thisGoal) <- should not be nil")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}//end of class













