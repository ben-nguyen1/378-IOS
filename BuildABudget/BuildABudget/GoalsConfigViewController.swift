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
}

protocol ValidDateDelegate {
    
    func isValidDate(inputDateString: String) -> Bool
}

protocol DeleteGoalDelegate {
    
    func deleteThisGoal( goalToDelete: MyGoal )
}


class GoalsConfigViewController: UIViewController, UITextFieldDelegate {

    var GoalsConfigAccess = AccessService.access
    
    var validGoalDelegate: EditGoalDelegate!
    var deleteGoalDelegate: DeleteGoalDelegate!
    let thisDate = MyDate.dateConverter //gives us access to the MyDate methods
    var thisGoal:MyGoal?            //= nil //must be var because this could be overwritten by a cell seque.
    //var existingGoalCopy:MyGoal?    = nil //a copy of an existing goal that is only used to compare its attribute values against any new textfield input
    var isNewGoal                   = true //value is only changed when the GoalsCell segue sets this to false to indicate thisGoal is an existing MyGoal
    
    @IBOutlet weak var nameTextField:                UITextField!
    @IBOutlet weak var targetAmountTextField:        UITextField!
    @IBOutlet weak var targetDateTextField:          UITextField!
    @IBOutlet weak var monthlyContributionTextField: UITextField!
    
    @IBOutlet weak var estimatedCompletionDateLabel: UILabel!
    @IBOutlet weak var progressPercentLabel:         UILabel!
    @IBOutlet weak var goalProgressbar:              UIProgressView!
    @IBOutlet weak var amountRemainingLabel:         UILabel!
    
    @IBAction func cancelButton(_ sender: Any) {} //button action only returns you to GoalsVC screen
    @IBAction func saveGoalButton(_ sender: Any) {
        
        //grab all the data from the alert window's text fields -> we are bringing them in as string first and checking that the input is valid
        guard let newNameString                 = self.nameTextField?.text                else { return }
        guard let newMonthlyContributionString  = self.monthlyContributionTextField?.text else { return }
        guard let newTargetDateString           = self.targetDateTextField?.text          else { return }
        guard let newTargetAmountString         = self.targetAmountTextField?.text        else { return }
        
        let noEmptyFields: Bool     = allFieldsFilledOut()
        let fieldsWereChanged: Bool = existingGoalValuesChangedByUser( inputNameString:                newNameString,
                                                                       inputTargetDateString:          newMonthlyContributionString,
                                                                       inputMonthlyContributionString: newTargetDateString,
                                                                       inputTargetAmountString:        newTargetAmountString )
        
        if isNewGoal == true && noEmptyFields {
            
            thisGoal = MyGoal.create( iContributionList:    [],
                                      iDescription:         newNameString,
                                      iMonthlyContribution: Double(newMonthlyContributionString)!,
                                      iStartDate:           Date(),
                                      iTargetDate:          thisDate.stringToDate(inputString: newTargetDateString),
                                      iTargetAmount:        Double(newTargetAmountString)! )
            
            thisGoal?.saveMyGoal(inputGoal: thisGoal!)//pass this newly constructed MyGoal object to MyGoal class to be saved
        }
        else if isNewGoal == false && noEmptyFields && fieldsWereChanged {
            
            print("!!! TEST: thisGoal = \(String(describing: thisGoal))")
            //since we are not allowing duplicate MyGoal records we have to delete the original thisGoal from CoreDate
            if self.thisGoal === nil {
                print("HELP: this goal is nil -> thisGoal == \(String(describing: thisGoal!))")
                return //void return to avoid crashing
            }
            else {
                print("HELP: this goal is not nil")
            }
            
            //validGoalDelegate.isUniqueGoalName( inputNameString: inputName)
            //let tempGoal:MyGoal = self.thisGoal!
            //deleteGoalDelegate.deleteThisGoal(goalToDelete: tempGoal )
            GoalsConfigAccess.deleteGoal(input: thisGoal!)
            
            //Now that the original thisGoal is not in CoreDate we can save an updated version of thisGoal
            thisGoal = MyGoal.create( iContributionList:    [],
                                      iDescription:         newNameString,
                                      iMonthlyContribution: Double(newMonthlyContributionString)!,
                                      iStartDate:           Date(),
                                      iTargetDate:          thisDate.stringToDate(inputString: newTargetDateString),
                                      iTargetAmount:        Double(newTargetAmountString)! )
            
            thisGoal?.saveMyGoal(inputGoal: thisGoal!)//pass this newly constructed MyGoal object to MyGoal class to be saved
        }
        else {
            print("ERROR: no goals Saved")//error
        }
    }
    
    
    
    func allFieldsFilledOut() -> Bool{
        
        if ( nameTextField.text!.isEmpty ||
             targetDateTextField.text!.isEmpty ||
             monthlyContributionTextField.text!.isEmpty ||
             targetAmountTextField.text!.isEmpty
            ){
                print("ERROR: not all fields are filled out")
                return false
            }
            else {
                return true
            }
    }
    
    //only called when isNewGoal == false <- this func evaluates if the existing MyGoal object values are the same as those the user filled out
    func existingGoalValuesChangedByUser( inputNameString: String,
                                          inputTargetDateString: String,
                                          inputMonthlyContributionString: String,
                                          inputTargetAmountString: String
                                         ) -> Bool{
        
        //if the user either did not change any field or did so only to change the value of the changed field back to the original value
        if (thisGoal?.desciption                    == inputNameString                &&
            thisGoal?.tagetDateToString()           == inputTargetDateString          &&
            thisGoal?.monthlyContributionToString() == inputMonthlyContributionString &&
            thisGoal?.targetAmountToString()        == inputTargetAmountString ) {
            
            return false
        }
        else {
            return true //the user must have changed one field from its existing value
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
    
    
    
    
    //Displays UIDatePicker upon targetDateTextField selection.
    func showGoalsDatePickerKeyboard(textField: UITextField) {
        if textField == targetDateTextField {//set the text field that should display the UIDatePicker
            let myDatePicker = UIDatePicker()
            myDatePicker.datePickerMode = .date
            myDatePicker.minimumDate    = Date()
            textField.inputView         = myDatePicker
            myDatePicker.addTarget(self, action: #selector(setSelectedDate(sender: )), for: .valueChanged) //this sends the currently selected date at every instance that user pauses to the setSelectedDate(sender: UIDatePicker) method
        }
    }
    
    //this func sets each input passed to it to a string and sets the dueDateTextField to the resulting string
    func setSelectedDate(sender: UIDatePicker) {
        targetDateTextField?.text = thisDate.dateToString(inputDate: (sender.date))
    }
    
    
    
    
    
    //Required ViewController functions below:
    override func viewDidLoad() {
        super.viewDidLoad()
        print("\n>>>REACHED GOALSCONFIGVC")
        
        // set keyboard dismiss
        nameTextField.delegate = self;
        targetAmountTextField.delegate = self;
        targetDateTextField.delegate = self;
        monthlyContributionTextField.delegate = self;
        
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
    
    // This method is called when the user touches the Return key on the
    // keyboard. The 'textField' passed in is a pointer to the textField
    // the cursor was in at the time they touched the Return key on the
    // keyboard.
    //
    // From the Apple documentation: Asks the delegate if the text field
    // should process the pressing of the return button.
    //
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 'First Responder' is the same as 'input focus'.
        // We are removing input focus from the text field.
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user touches on the main view (outside the UITextField).
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}//end of class













