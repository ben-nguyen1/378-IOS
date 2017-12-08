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
    var thisGoal:MyGoal? //= nil //must be var because this could be overwritten by a cell seque.
    var isNewGoal = true //value is only changed when the GoalsCell segue sets this to false to indicate thisGoal is an existing MyGoal
    let bvc = BudgetViewController.bc
    let reminder = Reminders.agent
    let transactionAgent = MyTransaction.agent

    static let gcvc = GoalsConfigViewController()
    @IBOutlet weak var errorMessageLabel: UILabel!
    @IBOutlet weak var nameTextField:                UITextField!
    @IBOutlet weak var targetAmountTextField:        UITextField!
    @IBOutlet weak var targetDateTextField:          UITextField!
    @IBOutlet weak var monthlyContributionTextField: UITextField!
    @IBOutlet weak var estimatedCompletionDateLabel: UILabel!
    @IBOutlet weak var progressPercentLabel:         UILabel!
    @IBOutlet weak var goalProgressbar:              UIProgressView!
    @IBOutlet weak var amountRemainingLabel:         UILabel!
    
    //Set custom colors
    let moneyPositiveColor = UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)    //hex: 0x51A453
    let textFieldErrorColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0) //hex: FF0000
    
    @IBAction func cancelButton(_ sender: Any) {} //button action only returns you to GoalsVC screen
    
    @IBAction func saveGoalButton(_ sender: Any) {
        
        //grab all the data from the alert window's text fields -> we are bringing them in as string first and checking that the input is valid
        guard let newNameString                 = self.nameTextField?.text                else { return }
        guard let newMonthlyContributionString  = self.monthlyContributionTextField?.text else { return }
        guard let newTargetDateString           = self.targetDateTextField?.text          else { return }
        guard let newTargetAmountString         = self.targetAmountTextField?.text        else { return }
        
        let noEmptyFields:     Bool = allFieldsFilledOut()
        let fieldsWereChanged: Bool = existingGoalValuesChangedByUser( inputNameString:                newNameString,
                                                                       inputTargetDateString:          newTargetDateString,
                                                                       inputMonthlyContributionString: newMonthlyContributionString,
                                                                       inputTargetAmountString:        newTargetAmountString )
        //check name field
        if ((self.nameTextField?.text)?.isEmpty)! {
            self.nameTextField?.layer.borderColor = textFieldErrorColor.cgColor
            self.nameTextField?.layer.borderWidth = 1.0
            errorMessageLabel.text = "Goal name cannot be blank"
            return
        }else {
            self.nameTextField?.layer.borderColor = UIColor.white.cgColor
        }
        
        //check TargetAmount Field
        if newTargetAmountString.isEmpty{
            self.targetAmountTextField?.layer.borderColor = textFieldErrorColor.cgColor
            self.targetAmountTextField?.layer.borderWidth = 1.0
            errorMessageLabel.text = "Target Amount cannot be blank"
            return
        } else if self.bvc.isValidAmount(inputMoneyString: newTargetAmountString) == false {
            self.targetAmountTextField?.layer.borderColor = textFieldErrorColor.cgColor
            self.targetAmountTextField?.layer.borderWidth = 1.0
            errorMessageLabel.text = "Amount must be between 0.00 and 100000000.00"
            return
        } else {
            self.targetAmountTextField?.layer.borderColor = UIColor.white.cgColor
        }
        
        //check TargetDate field
        let yesterday:Date = self.thisDate.setToYesterday(today: Date())
        let inputDate:Date = self.thisDate.stringToDate(inputString: newTargetDateString )
        let isValidDateFormat:Bool = self.thisDate.isValidMMDDYYYYFormat(inputDateString: newTargetDateString)
        
        if newTargetDateString.isEmpty {
            self.targetDateTextField?.layer.borderColor = textFieldErrorColor.cgColor
            self.targetDateTextField?.layer.borderWidth = 1.0
            errorMessageLabel.text = "Target Date cannot be blank"
            
            return
        } else if inputDate < yesterday {
            self.targetDateTextField?.layer.borderColor = textFieldErrorColor.cgColor
            self.targetDateTextField?.layer.borderWidth = 1.0
            errorMessageLabel.text = "Date cannot be in the past"
            return
        }else if isValidDateFormat == false  {
            self.targetDateTextField?.layer.borderColor = textFieldErrorColor.cgColor
            self.targetDateTextField?.layer.borderWidth = 1.0
            errorMessageLabel.text = "Please enter a date in MM/DD/YYYY format"
            
            return
        }  else {
            self.targetDateTextField?.layer.borderColor = UIColor.white.cgColor
        }
        
        //check Monthly Contribution Field
        if newMonthlyContributionString.isEmpty{
            self.monthlyContributionTextField?.layer.borderColor = textFieldErrorColor.cgColor
            self.monthlyContributionTextField?.layer.borderWidth = 1.0
            errorMessageLabel.text = "Monthly Contribution cannot be blank"
            
            return
        } else if self.bvc.isValidAmount(inputMoneyString: newMonthlyContributionString) == false {
            self.monthlyContributionTextField?.layer.borderColor = textFieldErrorColor.cgColor
            self.monthlyContributionTextField?.layer.borderWidth = 1.0
            errorMessageLabel.text = "Amount must be between 0.00 and 100000000.00"
            
            return
        } else {
            self.monthlyContributionTextField?.layer.borderColor = UIColor.white.cgColor
        }
        
        //let test = transactionLinkedToGoalStillExists(inputGoalDescription: thisGoal?.desciption )
        //print("TEST RESULTS = \(test)")
            
        if isNewGoal == true && noEmptyFields {
            
            thisGoal = MyGoal.create( iContributionList:    0.0,
                                      iDescription:         newNameString,
                                      iMonthlyContribution: Double(newMonthlyContributionString)!,
                                      iStartDate:           Date(),
                                      iTargetDate:          thisDate.stringToDate(inputString: newTargetDateString),
                                      iTargetAmount:        Double(newTargetAmountString)! )
            
            thisGoal?.saveMyGoal(inputGoal: thisGoal!)//pass this newly constructed MyGoal object to MyGoal class to be saved
            
            //save the monthly contribution as an expense
            saveNewMonthlyContributionAsBudgetExpense(inputGoal: thisGoal!)
            self.sequeBackToGoalsVC( conditional: true)
        } else if ( (isNewGoal == false && noEmptyFields && fieldsWereChanged == true) || (transactionLinkedToGoalStillExists(inputGoalDescription: (thisGoal?.desciption)! ) == false ) ) {
            //since we are not allowing duplicate MyGoal records we have to delete the original thisGoal from CoreDate
            if self.thisGoal === nil {
                print("HELP: this goal is nil -> thisGoal == \(String(describing: thisGoal!))")
                return //void return to avoid crashing
            }
            else {
                print("HELP: this goal is not nil")
            }
            
            let contributionTotal = thisGoal?.allContributions
            
            //delete the old instance of the transaction only if the MonthlyContribution text field has changed
            //if thisGoal?.monthlyContribution != Double(newMonthlyContributionString)! {
                var oldTransactionLinkedToThisGoal = MyTransaction.init()
                oldTransactionLinkedToThisGoal = oldTransactionLinkedToThisGoal.findMyTransactionLinkedToMyGoal(inputDescription: (thisGoal?.desciption)!)
                GoalsConfigAccess.deleteTransaction(input: oldTransactionLinkedToThisGoal)
            //}
            
            
            GoalsConfigAccess.deleteGoal(input: thisGoal!)
            
            //Now that the original thisGoal is not in CoreDate we can save an updated version of thisGoal
            thisGoal = MyGoal.create( iContributionList:    contributionTotal!,
                                      iDescription:         newNameString,
                                      iMonthlyContribution: Double(newMonthlyContributionString)!,
                                      iStartDate:           Date(),
                                      iTargetDate:          thisDate.stringToDate(inputString: newTargetDateString),
                                      iTargetAmount:        Double(newTargetAmountString)! )
  
            thisGoal?.saveMyGoal(inputGoal: thisGoal!)//pass this newly constructed MyGoal object to MyGoal class to be saved
        
            //save the monthly contribution as an expense
            saveNewMonthlyContributionAsBudgetExpense(inputGoal: thisGoal!)
            self.sequeBackToGoalsVC( conditional: true)
        } else {
            print("ERROR: no goals Saved")//error
        }
    }
    
    func transactionLinkedToGoalStillExists(inputGoalDescription: String ) -> Bool{
        print("MADE IT TO : transactionLinkedToGoalStillExists")
        var oldTransactionLinkedToThisGoal = MyTransaction.init()
        oldTransactionLinkedToThisGoal = oldTransactionLinkedToThisGoal.findReocurringMyTransactionLinkedToMyGoal(inputDescription: inputGoalDescription )
        print("oldTransactionLinkedToThisGoal = \(oldTransactionLinkedToThisGoal)")
        
        if oldTransactionLinkedToThisGoal.desciption == "error" {
            return false
        }
        else {
            return true
        }
    }
    
    func saveNewMonthlyContributionAsBudgetExpense( inputGoal: MyGoal) {
        
        var gDes = inputGoal.desciption
        var gTotalDue = inputGoal.monthlyContribution
        var gGoalName = inputGoal.desciption
        
        //all error checking is assumed to be completed in saveButton action
        
        let now = Date()
        let goalMonth:Int = thisDate.month(inputDate: now)
        let goalDay:Int = thisDate.day(inputDate: now)
        let goalYear:Int = thisDate.year(inputDate: now)
        let monthlyDueDate:Date = thisDate.makeDateSetToDay28(inputMonth: goalMonth, inputYear: goalYear)
        
        let newExpense = MyTransaction.create(iDes:              gDes,
                                              iIniDate:          Date(),
                                              iDueDate:          monthlyDueDate,
                                              iDatePaidOff:      MyDate.dateConverter.setToYesterday(today: Date()),
                                              iTotalDue:         gTotalDue,
                                              iIsReoccuring:     true,
                                              iIsIncome:         false,
                                              iLinkedToGoal:     gGoalName,
                                              iReminderID:       "",
                                              createNewReminder: true,
                                              callingVC:         self)
        
        
        //save the MyTransaction Object to CoreData
        AccessService.access.saveTransaction(input: newExpense)
    }
    
    func allFieldsFilledOut() -> Bool{
        
        if ( nameTextField.text!.isEmpty ||
            targetDateTextField.text!.isEmpty ||
            monthlyContributionTextField.text!.isEmpty ||
            targetAmountTextField.text!.isEmpty ){
                print("ERROR: not all fields are filled out")
                return false
        } else {
            return true
        }
    }
    
    //only called when isNewGoal == false <- this func evaluates if the existing MyGoal object values are the same as those the user filled out
    func existingGoalValuesChangedByUser( inputNameString: String,
                                          inputTargetDateString: String,
                                          inputMonthlyContributionString: String,
                                          inputTargetAmountString: String
        ) -> Bool{
        
        /*
        print("-------------------------------------------------------------------------")
        print("thisGoal?.desciption = \(thisGoal?.desciption) -> \(inputNameString)")
        if thisGoal?.desciption == inputNameString {
            print("---> true")
        }
        print("thisGoal?.tagetDateToString()  = \(thisGoal?.tagetDateToString()) -> \(inputTargetDateString )")
        if thisGoal?.tagetDateToString() == inputTargetDateString {
            print("---> true")
        }
        print("thisGoal?.monthlyContributionToString() = \(thisGoal?.monthlyContributionToString()) -> \(inputMonthlyContributionString)")
        if thisGoal?.monthlyContributionToString() == inputMonthlyContributionString {
            print("---> true")
        }
        print("thisGoal?.targetAmountToString() = \(thisGoal?.targetAmountToString()) -> \(inputTargetAmountString)")
        if thisGoal?.targetAmountToString() == inputTargetAmountString {
            print("---> true")
        }
        print("-------------------------------------------------------------------------")
        */
        
        //if the user either did not change any field or did so only to change the value of the changed field back to the original value
        if (thisGoal?.desciption                    == inputNameString                &&
            thisGoal?.tagetDateToString()           == inputTargetDateString          && //misspelling should not be corrected for BETA
            thisGoal?.monthlyContributionToString() == inputMonthlyContributionString &&
            thisGoal?.targetAmountToString()        == inputTargetAmountString ) {
            
            errorMessageLabel.text = "No changes were made."
            return false
        } else {
            
            return true //the user must have changed one field from its existing value
        }
    }
    
    //functions that check if user input is not an empty string and that it is a unique MyGoal description
    func checkGoalName( inputName:String) -> Bool{
        if  !inputName.isEmpty && validGoalDelegate.isUniqueGoalName( inputNameString: inputName) {
            return true
        } else {
            return false
        }
    }
    
    //checks if the goal does exist in the GoalsVC goalsList
    func isExistingGoal() -> Bool {
        if validGoalDelegate.isUniqueGoalName( inputNameString: (self.thisGoal?.desciption)! ){
            return true
        } else {
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
    
    func sequeBackToGoalsVC( conditional: Bool) {
        if( conditional == true ) {
            self.performSegue(withIdentifier: "backToGoalsVC", sender: self)
        }
    }
    
    //Required ViewController functions below:
    override func viewDidLoad() {
        
        super.viewDidLoad()
        print("\n>>>REACHED GOALSCONFIGVC")
        
        //set default error message
        errorMessageLabel.text  = ""
        if isNewGoal == false {
            let linkedTransactionStillExists = transactionAgent.findReocurringMyTransactionLinkedToMyGoal(inputDescription: (thisGoal?.desciption)!)
            if linkedTransactionStillExists.desciption == "error"{
                errorMessageLabel.text  = "Press SAVE to restore monthly contribution."
            }
        }
        
        // set keyboard dismiss
        nameTextField.delegate = self;
        targetAmountTextField.delegate = self;
        targetDateTextField.delegate = self;
        monthlyContributionTextField.delegate = self;
        
        //set keyboard types
        self.targetAmountTextField.keyboardType         = UIKeyboardType.decimalPad
        self.monthlyContributionTextField.keyboardType  = UIKeyboardType.decimalPad
        showGoalsDatePickerKeyboard(textField: self.targetDateTextField)
        
        if self.thisGoal != nil{
            
            //setup all UITextfields
            self.nameTextField.text                 = self.thisGoal?.desciption
            let inputTargetAmount = transactionAgent.getFormattedAmount(inputAmount: (self.thisGoal?.targetAmount)!)
            self.targetAmountTextField.text         = "\(inputTargetAmount)"//String(describing: self.thisGoal?.targetAmount)
            let tempDateToString:String             = thisDate.dateToString(inputDate: (self.thisGoal?.targetDate)!)
            self.targetDateTextField.text           = tempDateToString
            let inputMonthlyContribution = transactionAgent.getFormattedAmount(inputAmount: (self.thisGoal?.monthlyContribution)!)
            self.monthlyContributionTextField.text  = "\(inputMonthlyContribution)"
            
            //setup all UILabels
            self.estimatedCompletionDateLabel.text  = thisDate.dateToString(inputDate: (thisGoal?.getEstimatedCompletionDate())!)
            self.progressPercentLabel.text          = thisGoal?.getProgressString()
            self.amountRemainingLabel.text          = String(describing: (thisGoal?.getRemainingAmount())! )
            
            self.progressPercentLabel.text          = self.progressPercentLabel.text! + "%"
            let inputAmountRemaining = transactionAgent.getFormattedAmount(inputAmount: (self.thisGoal?.getRemainingAmount())!)

            self.amountRemainingLabel.text          = "\(Account.currency()) " + inputAmountRemaining
            
            let inputProgress = self.thisGoal?.getProgress()
            //let progressBarPercent = setupProgressBar(inputPercentProgress: (inputProgress * 0.1) * 0.1)
            let inputProgressBarPercent = (self.thisGoal?.getProgress())!
            self.goalProgressbar.setProgress( (( inputProgressBarPercent * 0.1) * 0.1), animated: false)

        } else {
            
            self.estimatedCompletionDateLabel.text  = ""
            self.progressPercentLabel.text          = ""
            self.amountRemainingLabel.text          = ""
            
            self.goalProgressbar.setProgress( 0.0 , animated: false)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
  
}//end of class
