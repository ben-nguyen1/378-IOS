//
//  ChecklistViewController.swift
//  BuildABudget
//
//  Created by Nicholas Cobb on 10/25/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//]
import UIKit

class ChecklistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var unpaidTableView: UITableView!
    @IBOutlet weak var paidTableView: UITableView!
    
    // Var with ability to interface with the coreData storage methods
    let ChecklistAccess = AccessService.access
    let GoalsVC = GoalsViewController.gvc
    let transactionAgent = MyTransaction.agent
    
    var dateConverter = MyDate()
    var unpaidItems: [MyTransaction] = []
    var paidItems: [MyTransaction] = []

    //UIAlert field vars
    var descriptionTextField: UITextField? = nil
    var costTextField: UITextField? = nil
    var dueDateTextField: UITextField? = nil
    
    //Delegate to access isValidAmount function from BudgetViewController
    var delegate: MoneyDelegate?
    var moneyValidator = BudgetViewController.bc
    
    //Set custom colors
    let moneyPositiveColor = UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)  //hex: 0x51A453
    let textFieldErrorColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0) //hex: FF0000
    
    override func viewDidLoad() {
        super.viewDidLoad()
        unpaidTableView.dataSource = self
        paidTableView.dataSource = self
        unpaidTableView.delegate = self
        paidTableView.delegate = self
        updateCheckListItems()
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //this method sorts all MyTransaction objects, which do not belong to completed goals, into paid and unpaid lists
    func updateCheckListItems() {
        unpaidItems = []
        paidItems = []

        
        ChecklistAccess.retreiveAllTransactions()
        var i = 0
        while (i < ChecklistAccess.totalTransactions()) {
            let currTransaction = ChecklistAccess.getTransaction(index: i)
            if (currTransaction.isReoccuring && !currTransaction.isIncome) {
                if (currTransaction.isPastDue()) {
                    paidItems.append(currTransaction)
                } else {
                    if currTransaction.linkedTransactionHasAmountGreaterThanZero(inputTransaction: currTransaction) == true {
                        unpaidItems.append(currTransaction)
                    }
                }
            }
            i += 1
        }
        print(i)
        
        
        //sort unpaidItems by dueDate
        var tempList = unpaidItems
        unpaidItems = tempList.sorted(by: { $0.dueDate > $1.dueDate }) //double check this implementation
        
        /*
        
        let list:[MyTransaction] = transactionAgent.getAllReoccuringTransactions()
        for item in list{
            if item.isReoccuring && !item.isIncome {
                if item.isPastDue() {
                    paidItems.append(item)
                }
                else {
                    unpaidItems.append(item)
                }
            }
        }
 */
    }
    
    func createOneTimeTransactionCopy( originalReoccurringTransaction: MyTransaction) -> MyTransaction {
        var copyOfOriginal = MyTransaction.init() //dummy value
        copyOfOriginal = copyOfOriginal.copy(originalTransaction: originalReoccurringTransaction)
        return copyOfOriginal
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTables()
    }
    
    func updateTables() {
        self.updateCheckListItems()
        self.paidTableView.reloadData()
        self.unpaidTableView.reloadData()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == unpaidTableView) {
            return unpaidItems.count
        } else if (tableView == paidTableView) {
            return paidItems.count
        }
        return 0
    }

    //swipe options
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let paid = UITableViewRowAction(style: .normal, title: "Paid") { action, index in
            var transactionToChange = self.unpaidItems[index.row]
            self.applyPaymentToGoal(inputTransaction: transactionToChange)
            self.ChecklistAccess.deleteTransaction(input: transactionToChange)
            
            transactionToChange.datePaidOff = Date()
            //now save a NON-reoccurring MyTransaction -> this will be used by TransactionViewController
            let copy = self.createOneTimeTransactionCopy(originalReoccurringTransaction: transactionToChange)
            self.ChecklistAccess.saveTransaction(input: copy)
            
            //now resave transactionToChange with new next month's due date -> ex: if this due date is 12/8/2017 then next due date is 1/8/2018
            transactionToChange.dueDate = self.dateConverter.getDateXNumDaysFromNow(inputStartDate: transactionToChange.dueDate, inputXNumDays: 30) //may want to change the static 30 days input to reflect varying month lengths
            self.ChecklistAccess.saveTransaction(input: transactionToChange)
            self.updateTables()
            print("paid button tapped \(index.row)")
            
            
        }
        paid.backgroundColor = UIColor.green
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            self.ChecklistAccess.deleteTransaction(input: self.unpaidItems[index.row])
            self.updateTables()
            print("delete button tapped \(index.row)")
        }
        delete.backgroundColor = UIColor.red
        
        return [paid, delete]
    }
    
    func applyPaymentToGoal(inputTransaction: MyTransaction) {
        let targetGoal = GoalsVC.getSpecificGoal(goalName: inputTransaction.linkedToGoal)
        if targetGoal.desciption == "error"{
            //print("Could not find MyTransaction linked to \(inputTransaction.linkedToGoal)")
            return
        }
        else {
            //add the totalDue amount from the transaction to the goal's contributionList
            //print(">>>Applying payment to goal \(targetGoal.desciption) , original contributionList = \(targetGoal.allContributions)")
            targetGoal.allContributions += inputTransaction.totalDue
            //print(">>>Payment to goal \(targetGoal.desciption) , new contributionList = \(targetGoal.allContributions)")
            
            //save this updated goal by deleting the old instance of the goal and then saving targetGoal
            ChecklistAccess.deleteGoal(input: targetGoal)
            ChecklistAccess.saveGoal(input: targetGoal)
            print(">>>Checklist: \(targetGoal)")
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView == self.unpaidTableView
    }
    
    //setup the table cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.unpaidTableView) { //top UITableView
            let cell = tableView.dequeueReusableCell(withIdentifier: "unpaidCell")! as! ChecklistUnpaidTableViewCell
            let currItem = unpaidItems[indexPath.row]
            
            if (currItem.desciption.count < 8) {
                cell.expenseLabel!.text = currItem.desciption
            } else {
                let index = currItem.desciption.index(currItem.desciption.startIndex, offsetBy: 5)
                cell.expenseLabel!.text = currItem.desciption.substring(to: index) + "..."
            }
            let currency = Account.currency()
            cell.amountLabel!.text = "\(currency)\(currItem.totalDue)"
            cell.dueDateLabel.text = dateConverter.shortDateToString(inputDate: currItem.dueDate)
            
            
            if self.dateConverter.day(inputDate: currItem.dueDate) <= self.dateConverter.day(inputDate: Date()) || currItem.isPastDue() {
                cell.contentView.backgroundColor = UIColor.orange
            }
            return cell
        } else {
            let currency = Account.currency()
            let newCell = tableView.dequeueReusableCell(withIdentifier: "paidCell") as! ChecklistPaidTableViewCell
            let currItem = paidItems[indexPath.row]

            newCell.amountLabel.text = "\(currency)\(currItem.totalDue)"
            newCell.dateLabel!.text = dateConverter.shortDateToString(inputDate: currItem.datePaidOff)
            
            if (currItem.desciption.count < 8) {
                newCell.expenseLabel!.text = currItem.desciption
            } else {
                let index = currItem.desciption.index(currItem.desciption.startIndex, offsetBy: 5)
                newCell.expenseLabel!.text = currItem.desciption.substring(to: index) + "..."
            }
            return newCell
        }
    }
    
    @IBAction func addExpense(_ sender: Any) {
        addExpense( errorField: "none", errorMessage: "Enter the details for the new checklist expense.", previousTextFieldInput: [])
    }
    
    func addExpense( errorField: String, errorMessage: String, previousTextFieldInput: [String]) {
        
        let alertWindowTitle:   String = "Add Income"
        var description:        String = ""
        var transactionDate:    Date? = nil
        var cost:               Double = 0.0
        
        //set the AlertWindow's title and instruction message to user
        let CheckListAddExpenseWindow = UIAlertController(title: alertWindowTitle, message: errorMessage, preferredStyle: .alert)
        
        //do not change the order of these three .addTextFields
        CheckListAddExpenseWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
        }
        
        CheckListAddExpenseWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            self.costTextField = textField
            self.costTextField?.keyboardType = UIKeyboardType.decimalPad
        }
        
        CheckListAddExpenseWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 01/09/2017"
            self.dueDateTextField = textField
        }
        
        //handle previously passed errors
        if errorField != "none" {
            
            if errorField == "descriptionTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.descriptionTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.descriptionTextField?.layer.borderWidth = 1.0
                CheckListAddExpenseWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.costTextField?.text = previousTextFieldInput[1]
                self.dueDateTextField?.text = previousTextFieldInput[2]
                
            }
            else if errorField == "costTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.costTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.costTextField?.layer.borderWidth = 1.0
                CheckListAddExpenseWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.descriptionTextField?.text = previousTextFieldInput[0]
                self.dueDateTextField?.text = previousTextFieldInput[2]
            }
            else if errorField == "dueDateTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.dueDateTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.dueDateTextField?.layer.borderWidth = 1.0
                CheckListAddExpenseWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.descriptionTextField?.text = previousTextFieldInput[0]
                self.costTextField?.text = previousTextFieldInput[1]
            }
            else {
                print("We should not have reached this point -> exiting UIAlertController now")
                return
            }
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
            
            //grab all the data from the alert window's text fields
            var rawTextFieldInput: [String] = []
            rawTextFieldInput.append( (self.descriptionTextField?.text)! )
            rawTextFieldInput.append( (self.costTextField?.text)! )
            rawTextFieldInput.append( (self.dueDateTextField?.text)! )
            
            
            guard let descriptionTextField = self.descriptionTextField?.text , self.isValidCheckListDescription(input: (self.descriptionTextField?.text)!) else {
                
                self.addExpense( errorField: "descriptionTextField", errorMessage: "Description cannot be blank", previousTextFieldInput: rawTextFieldInput)
                print("bad input description")
                return
            }
            
            guard let costTextField = self.costTextField?.text , self.moneyValidator.isValidAmount(inputMoneyString: (self.costTextField?.text)! )  else {
                
                self.addExpense( errorField: "costTextField", errorMessage: "Amount must be between 0.00 and 100000000.00", previousTextFieldInput: rawTextFieldInput)
                print("bad input amount")
                return
            }
            
            let yesterday:Date = self.dateConverter.setToYesterday(today: Date())
            let inputDate:Date = self.dateConverter.stringToDate(inputString: (self.dueDateTextField?.text)!)
            let isValidDateFormat:Bool = self.dateConverter.isValidMMDDYYYYFormat(inputDateString: (self.dueDateTextField?.text)!)
            
            guard let dueDateTextField = self.dueDateTextField?.text,  !(self.dueDateTextField?.text?.isEmpty)!, inputDate > yesterday, isValidDateFormat else {
                
                if (self.dueDateTextField?.text?.isEmpty)! {
                    self.addExpense( errorField: "dueDateTextField", errorMessage: "Date cannot be blank", previousTextFieldInput: rawTextFieldInput)
                    print("bad input due date")
                    return
                }
                
                if !(inputDate > yesterday) {
                    self.addExpense( errorField: "dueDateTextField", errorMessage: "Date cannot be in the past", previousTextFieldInput: rawTextFieldInput)
                    print("bad input due date")
                    return
                }
                
                self.addExpense( errorField: "dueDateTextField", errorMessage: "Please enter a date in MM/DD/YYYY format", previousTextFieldInput: rawTextFieldInput)
                print("bad input due date")
                return
            }
            
            //set the data that we grabbed into local variables
            description = descriptionTextField
            transactionDate = self.dateConverter.stringToDate(inputString: dueDateTextField)
            let datePaidOff = self.dateConverter.setToYesterday(today: Date()) //added by chris 
            cost = (costTextField as NSString).doubleValue
            
            let newExpense = MyTransaction.create(iDes: description,
                                                  iIniDate: Date(),
                                                  iDueDate: transactionDate!,
                                                  iDatePaidOff: datePaidOff,
                                                  iTotalDue: cost,
                                                  iIsReoccuring: true,
                                                  iIsIncome: false,
                                                  iLinkedToGoal: "",
                                                  iReminderID: "",
                                                  createNewReminder: true,
                                                  callingVC: self)
            
            self.ChecklistAccess.saveTransaction(input: newExpense)
            self.updateTables()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
        }
        
        //add the buttons to the Alert window
        CheckListAddExpenseWindow.addAction(saveAction)
        CheckListAddExpenseWindow.addAction(cancelAction)
        
        showChecklistDatePickerKeyboard(textField: dueDateTextField!)
        //display the alert window on the screen
        present(CheckListAddExpenseWindow, animated: true, completion: nil)
    }
    
    //UIAlert window input validation methods
    func isValidCheckListDescription( input:String) -> Bool{
        if  !input.isEmpty {//basically any charactes will do as long as something is input
            return true
        }
        else {
            return false
        }
    }
    
    //Displays UIDatePicker upon targetDateTextField selection.
    func showChecklistDatePickerKeyboard(textField: UITextField) {
        if textField == dueDateTextField {//set the text field that should display the UIDatePicker
            let myDatePicker = UIDatePicker()
            myDatePicker.datePickerMode = .date
            myDatePicker.minimumDate    = Date()
            textField.inputView         = myDatePicker
            myDatePicker.addTarget(self, action: #selector(setSelectedDate(sender: )), for: .valueChanged) //this sends the currently selected date at every instance that user pauses to the setSelectedDate(sender: UIDatePicker) method
        }
    }
    
    //this func sets each input passed to it to a string and sets the dueDateTextField to the resulting string
    func setSelectedDate(sender: UIDatePicker) {
        dueDateTextField?.text = dateConverter.dateToString(inputDate: (sender.date))
    }
}
