//
//  BudgetViewController.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
protocol MoneyDelegate {
    func isValidAmount( inputMoneyString: String? ) -> Bool
}

import UIKit
import Foundation

class BudgetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, MoneyDelegate {
    
    @IBAction func addIncomeButton(_ sender: Any) {
        self.addIncome( errorField: "none", errorMessage: "Fill out all fields", previousTextFieldInput: [])
    }
    
    @IBAction func addExpenseButton(_ sender: Any) {
        addExpense( errorField: "none", errorMessage: "Fill out all fields", previousTextFieldInput: [])
    }
    
    @IBOutlet weak var incomeTable: UITableView! //has attribute .tag = 111
    @IBOutlet weak var expenseTable: UITableView! //has attribute .tag = 222
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    
    @IBOutlet weak var extraIncomeLabel: UILabel!
    @IBOutlet weak var extraExpenseLabel: UILabel!
    
    fileprivate var incomeList: [MyTransaction] = []
    fileprivate var expenseList: [MyTransaction] = []
    fileprivate var thisBudget: MyBudget? = nil
    
    var incomeTotal:Double = 0.0
    var expenseTotal:Double = 0.0
    var differenceAmount = 0.0

    //UIAlert field vars
    var descriptionTextField: UITextField? = nil
    var dueDateTextField: UITextField? = nil
    var totalDueTextField: UITextField? = nil
    
    //var with ability to interface with the coreData storage methods
    var BudgetAccess = AccessService.access
    let thisDate = MyDate.dateConverter
    static let bc = BudgetViewController()
    let transactionAgent = MyTransaction.agent
    
    //var dueDatePicker
    let dueDatePicker = UIDatePicker()
    
    //Set custom colors
    let moneyPositiveColor = UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)  //hex: 0x51A453
    let textFieldErrorColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0) //hex: FF0000
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        thisBudget = BudgetAccess.getBudget(index: 0) //we only allow one MyBudget object in this app per initial project specifications - future revisions could allow for multiple budgets
        self.update()
    }
    
    //return number of rows for a specific tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if tableView.tag == 111{//incomeTable
            return incomeList.count //+ 1
        }
        else if tableView.tag == 222{//expenseTable
            return expenseList.count //+ 1
        }
        else {
            return 0 //catches tableview tags that are not incomeTable or expenseTable tags
        }
    }
    
    //populate each table with TableViewCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (tableView == self.incomeTable){//tableView.tag == 111    incomeTable
            let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetLineCell", for: indexPath) as! BudgetLineCell
            //set up the cell
            let shortDate = thisDate.shortDateToString(inputDate: (incomeList[indexPath.item].dueDate) )
            let totalDue = transactionAgent.getFormattedAmount(inputAmount: incomeList[indexPath.item].totalDue)
            cell.config(inputName: incomeList[indexPath.item].desciption, inputDate: shortDate, inputAmount: totalDue ) //may need to chnage how to parameters dueDate and amount are converted to string.
            cell.inViewTable = 111
            return cell
        }
        else {//expenseTable
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetExpenseCell", for: indexPath) as! BudgetExpenseCell
            //set up the cell
            var dueDate = expenseList[indexPath.item].dueDate
            if dueDate < Date() { //if the due date has passed
                dueDate = thisDate.getDateXNumDaysFromNow(inputStartDate: dueDate, inputXNumDays: 30)
            }
            let shortDate = thisDate.shortDateToString(inputDate: dueDate )
            let temp = expenseList[indexPath.item].adjustExpenseAmountDouble(inputTransaction: expenseList[indexPath.item] )
            let amount = transactionAgent.getFormattedAmount(inputAmount: temp)
            cell.config(inputName: expenseList[indexPath.item].desciption, inputDate: shortDate, inputAmount: amount) //may need to chnage how to parameters dueDate and amount are converted to string.
            cell.inViewTable = 222
            return cell
        }
    }
    
    //UIAlert window that allows user to input the Description, Amount, and Due Date of their new expense or income
    func launchAlertWindow(tableValueInput: Int) {
        
        var alertWindowTitle:   String = ""
        var description:        String = ""
        var dueDate:            Date? = nil
        var totalDue:           Double = 0.0
        var isIncome:           Bool = false //only changed if add button from incomeTable is pressed
        
        //set title of window accordingly
        if tableValueInput == 111 {// 111 means we are in the incomeTable
            alertWindowTitle = "New Monthly Income"
            isIncome = true
        }
        else {// this means that our inViewTable tag is 222 and we are in the expenseTable
            alertWindowTitle = "New Monthly Expense"
        }
        
        //set the AlertWindow's title and instruction message to user
        let newBudgetLineInputWindow = UIAlertController(title: alertWindowTitle, message: "Fill out all fields", preferredStyle: .alert)
        
        //do not change the order of these three .addTextFields
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
            
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            self.totalDueTextField = textField
            //self.totalDueTextField?.backgroundColor = UIColor.blue <----- experimented with background colors (future use)
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 01/09/2017"
            self.dueDateTextField = textField
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
            
            //grab all the data from the alert window's text fields
            guard let descriptionTextField = self.descriptionTextField?.text, self.isValidDescription(input: (self.descriptionTextField?.text)!) else { return }
            guard let totalDueTextField = self.totalDueTextField?.text else { return }
            guard let dueDateTextField = self.dueDateTextField?.text else { return }
            
            //set the data that we grabbed into local variables
            description = descriptionTextField
            dueDate = MyDate.dateConverter.stringToDate(inputString: dueDateTextField)
            totalDue = (totalDueTextField as NSString).doubleValue
            
            //Build the MyTransaction Object
            let newBudgetItem = MyTransaction.create(iDes:              description,
                                                     iIniDate:          Date(),
                                                     iDueDate:          dueDate!,
                                                     iDatePaidOff:      MyDate.dateConverter.setToYesterday(today: Date()),
                                                     iTotalDue:         totalDue,
                                                     iIsReoccuring:     true,
                                                     iIsIncome:         isIncome,
                                                     iLinkedToGoal:     "",
                                                     iReminderID:       "",
                                                     createNewReminder: true,
                                                     callingVC:         self )
            
            //save the MyTransaction Object to CoreData
            AccessService.access.saveTransaction(input: newBudgetItem)
            
            self.update()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
        }
        
        //add the buttons to the Alert window
        newBudgetLineInputWindow.addAction(saveAction)
        newBudgetLineInputWindow.addAction(cancelAction)
        
        //display the alert window on the screen
        present(newBudgetLineInputWindow, animated: true, completion: nil)
    }
    
    //UIAlert window input validation methods
    func isValidDescription( input:String) -> Bool{
        if  !input.isEmpty {//basically any charactes will do as long as something is input
            return true
        }
        else {
            return false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //set each table's data source
        incomeTable.dataSource = self
        expenseTable.dataSource = self
        
        //set each table's delegate
        incomeTable.delegate = self
        expenseTable.delegate = self
        navigationItem.title = "Budget"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //update incomeList, expenseList, incomeTotal, expenseTotal
    func update(){
        
        BudgetAccess.retreiveAllTransactions()//cause all transactions to be reloaded by CoreDate interface
        
        //set all lists and counters to 0
        incomeList = []
        expenseList = []
        incomeTotal = 0.0
        expenseTotal = 0.0
        
        var i = 0
        let limit = BudgetAccess.totalTransactions()
        for i in 0..<limit {
            let temp = BudgetAccess.getTransaction(index: i)
            if temp.isReoccuring {
                if temp.isIncome {
                    incomeList.append(temp)
                    incomeTotal += temp.totalDue
                }
                else {
                    expenseList.append(temp)
                    expenseTotal += temp.adjustExpenseAmountDouble(inputTransaction: temp)
                }
            }
        }
        
        //calculate the budget deficit/surplus
        differenceAmount = incomeTotal - expenseTotal
        
        //display the incomeTotal, expenseTotal, differenceAmount on view controller
        self.incomeLabel.text = String(format: "\(Account.currency())   %.2F", incomeTotal)
        self.expenseLabel.text = String(format: "\(Account.currency()) -%.2F", expenseTotal)
        self.differenceLabel.text = String(format: "\(Account.currency())   %.2F", differenceAmount)
        self.extraIncomeLabel.text = String(format: "\(Account.currency()) %.2F", incomeTotal)
        self.extraExpenseLabel.text = String(format: "\(Account.currency()) %.2F", expenseTotal)
        
        //change differenceLabel text color if value is positive or negative
        if differenceAmount >= 0.0 {
            self.differenceLabel.textColor = moneyPositiveColor //= UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)
            self.differenceLabel.text = String(format: "\(Account.currency())   %.2F", differenceAmount)
        }
        else {
            self.differenceLabel.textColor = UIColor.red
            self.differenceLabel.text = String(format: "\(Account.currency()) %.2F", differenceAmount)
        }
        
        //reload the UITables to display the new transaction data
        self.incomeTable.reloadData()
        self.expenseTable.reloadData()
    }
    
    func addIncome( errorField: String, errorMessage: String, previousTextFieldInput: [String] ) {
        
        let alertWindowTitle:   String = "Add Income"
        var description:        String = ""
        var dueDate:            Date? = nil
        var totalDue:           Double = 0.0
        let isIncome:           Bool = true
        
        //set the AlertWindow's title and instruction message to user
        let newBudgetLineInputWindow = UIAlertController(title: alertWindowTitle, message: errorMessage, preferredStyle: .alert)
        
        //do not change the order of these three .addTextFields
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            self.totalDueTextField = textField
            self.totalDueTextField?.keyboardType = UIKeyboardType.decimalPad
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 01/09/2017"
            self.dueDateTextField = textField
        }
        
        //handle previously passed errors
        if errorField != "none" {
            
            if errorField == "descriptionTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.descriptionTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.descriptionTextField?.layer.borderWidth = 1.0
                newBudgetLineInputWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.totalDueTextField?.text = previousTextFieldInput[1]
                self.dueDateTextField?.text = previousTextFieldInput[2]
                
            }
            else if errorField == "totalDueTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.totalDueTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.totalDueTextField?.layer.borderWidth = 1.0
                newBudgetLineInputWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.descriptionTextField?.text = previousTextFieldInput[0]
                self.dueDateTextField?.text = previousTextFieldInput[2]
            }
            else if errorField == "dueDateTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.dueDateTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.dueDateTextField?.layer.borderWidth = 1.0
                newBudgetLineInputWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.descriptionTextField?.text = previousTextFieldInput[0]
                self.totalDueTextField?.text = previousTextFieldInput[1]
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
            rawTextFieldInput.append( (self.totalDueTextField?.text)! )
            rawTextFieldInput.append( (self.dueDateTextField?.text)! )
            
            guard let descriptionTextField = self.descriptionTextField?.text , self.isValidDescription(input: (self.descriptionTextField?.text)!) else {
                
                self.addIncome( errorField: "descriptionTextField", errorMessage: "Description cannot be blank", previousTextFieldInput: rawTextFieldInput)
                //print("bad input description")
                return
            }
            
            guard let totalDueTextField = self.totalDueTextField?.text , self.isValidAmount(inputMoneyString: (self.totalDueTextField?.text)! ) else {
                
                self.addIncome( errorField: "totalDueTextField", errorMessage: "Amount must be between 0.00 and 100000000.00", previousTextFieldInput: rawTextFieldInput)
                //print("bad input amount")
                return
            }
            
            let yesterday:Date = self.thisDate.setToYesterday(today: Date())
            let inputDate:Date = self.thisDate.stringToDate(inputString: (self.dueDateTextField?.text)!)
            let isValidDateFormat:Bool = self.thisDate.isValidMMDDYYYYFormat(inputDateString: (self.dueDateTextField?.text)!)
            
            guard let dueDateTextField = self.dueDateTextField?.text,  !(self.dueDateTextField?.text?.isEmpty)!, inputDate > yesterday, isValidDateFormat else {
                
                if (self.dueDateTextField?.text?.isEmpty)! {
                    self.addIncome( errorField: "dueDateTextField", errorMessage: "Date cannot be blank", previousTextFieldInput: rawTextFieldInput)
                    return
                }
                
                if !(inputDate > yesterday) {
                    self.addIncome( errorField: "dueDateTextField", errorMessage: "Date cannot be in the past", previousTextFieldInput: rawTextFieldInput)
                    return
                }
                
                self.addIncome( errorField: "dueDateTextField", errorMessage: "Please enter a date in MM/DD/YYYY format", previousTextFieldInput: rawTextFieldInput)
                return
            }
            
            //set the data that we grabbed into local variables
            description = descriptionTextField
            dueDate = MyDate.dateConverter.stringToDate(inputString: dueDateTextField)
            totalDue = (totalDueTextField as NSString).doubleValue
            
            //Build the MyTransaction Object
            let newBudgetItem = MyTransaction.create(iDes:              description,
                                                     iIniDate:          Date(),
                                                     iDueDate:          dueDate!,
                                                     iDatePaidOff:      MyDate.dateConverter.setToYesterday(today: Date()),
                                                     iTotalDue:         totalDue,
                                                     iIsReoccuring:     true,
                                                     iIsIncome:         isIncome,
                                                     iLinkedToGoal:     "",
                                                     iReminderID:       "",
                                                     createNewReminder: true,
                                                     callingVC:         self )
            
            //save the MyTransaction Object to CoreData
            AccessService.access.saveTransaction(input: newBudgetItem)
            
            self.update()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
        }
        
        //add the buttons to the Alert window
        newBudgetLineInputWindow.addAction(saveAction)
        newBudgetLineInputWindow.addAction(cancelAction)
        
        showDatePickerKeyboard(textField: dueDateTextField!)
        //display the alert window on the screen
        present(newBudgetLineInputWindow, animated: true, completion: nil)
    }
    
    func addExpense( errorField: String, errorMessage: String, previousTextFieldInput: [String]) {
        
        let alertWindowTitle:   String = "Add Income"
        var description:        String = ""
        var dueDate:            Date? = nil
        var totalDue:           Double = 0.0
        let isIncome:           Bool = false
        
        //set the AlertWindow's title and instruction message to user
        let newBudgetLineInputWindow = UIAlertController(title: alertWindowTitle, message: errorMessage, preferredStyle: .alert)
        
        //do not change the order of these three .addTextFields
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            self.totalDueTextField = textField
            self.totalDueTextField?.keyboardType = UIKeyboardType.decimalPad
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 01/09/2017"
            self.dueDateTextField = textField
        }
        
        //handle previously passed errors
        if errorField != "none" {
            
            if errorField == "descriptionTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.descriptionTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.descriptionTextField?.layer.borderWidth = 1.0
                newBudgetLineInputWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.totalDueTextField?.text = previousTextFieldInput[1]
                self.dueDateTextField?.text = previousTextFieldInput[2]
                
            }
            else if errorField == "totalDueTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.totalDueTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.totalDueTextField?.layer.borderWidth = 1.0
                newBudgetLineInputWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.descriptionTextField?.text = previousTextFieldInput[0]
                self.dueDateTextField?.text = previousTextFieldInput[2]
            }
            else if errorField == "dueDateTextField" {
                
                //set red boarder around error text field and show instructions at the top of the UIAlert window
                self.dueDateTextField?.layer.borderColor = self.textFieldErrorColor.cgColor
                self.dueDateTextField?.layer.borderWidth = 1.0
                newBudgetLineInputWindow.message = errorMessage
                
                //fill in the other two text fields with the previous input values
                self.descriptionTextField?.text = previousTextFieldInput[0]
                self.totalDueTextField?.text = previousTextFieldInput[1]
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
            rawTextFieldInput.append( (self.totalDueTextField?.text)! )
            rawTextFieldInput.append( (self.dueDateTextField?.text)! )
            
            guard let descriptionTextField = self.descriptionTextField?.text , self.isValidDescription(input: (self.descriptionTextField?.text)!) else {
                
                self.addExpense( errorField: "descriptionTextField", errorMessage: "Description cannot be blank", previousTextFieldInput: rawTextFieldInput)
                return
            }
            
            guard let totalDueTextField = self.totalDueTextField?.text , self.isValidAmount(inputMoneyString: (self.totalDueTextField?.text)! ) else {
                
                self.addExpense( errorField: "totalDueTextField", errorMessage: "Amount must be between 0.00 and 100000000.00", previousTextFieldInput: rawTextFieldInput)
                return
            }
            
            let yesterday:Date = self.thisDate.setToYesterday(today: Date())
            let inputDate:Date = self.thisDate.stringToDate(inputString: (self.dueDateTextField?.text)!)
            let isValidDateFormat:Bool = self.thisDate.isValidMMDDYYYYFormat(inputDateString: (self.dueDateTextField?.text)!)
            
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
            dueDate = MyDate.dateConverter.stringToDate(inputString: dueDateTextField)
            totalDue = (totalDueTextField as NSString).doubleValue
            
            //Build the MyTransaction Object
            let newBudgetItem = MyTransaction.create(iDes:              description,
                                                     iIniDate:          Date(),
                                                     iDueDate:          dueDate!,
                                                     iDatePaidOff:      MyDate.dateConverter.setToYesterday(today: Date()),
                                                     iTotalDue:         totalDue,
                                                     iIsReoccuring:     true,
                                                     iIsIncome:         isIncome,
                                                     iLinkedToGoal:     "",
                                                     iReminderID:       "",
                                                     createNewReminder: true,
                                                     callingVC:         self )
            
            //save the MyTransaction Object to CoreData
            AccessService.access.saveTransaction(input: newBudgetItem)
            
            self.update()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
        }
        
        //add the buttons to the Alert window
        newBudgetLineInputWindow.addAction(saveAction)
        newBudgetLineInputWindow.addAction(cancelAction)
        
        showDatePickerKeyboard(textField: dueDateTextField!)
        //display the alert window on the screen
        present(newBudgetLineInputWindow, animated: true, completion: nil)
    }
    
    //swipe to delete functionality
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
        if (tableView == self.incomeTable) {
            
            let removeIncome = UITableViewRowAction(style: .normal, title: "Delete") {action, index in
                
                let removedTransaction = self.incomeList[index.row]
                self.BudgetAccess.deleteTransaction(input: removedTransaction)
                self.update()
            }
            removeIncome.backgroundColor = UIColor.red
            return [removeIncome]
        }
        else {
            let removeExpense = UITableViewRowAction(style: .normal, title: "Delete") {
                action, index in
                self.BudgetAccess.deleteTransaction(input: self.expenseList[index.row])
                self.update()
            }
            removeExpense.backgroundColor = UIColor.red
            return [removeExpense]
        }
    }
    
    //Displays UIDatePicker upon text field selection.
    func showDatePickerKeyboard(textField: UITextField) {
        if textField == dueDateTextField {//set the text field that should display the UIDatePicker
            let myDatePicker = UIDatePicker()
            myDatePicker.datePickerMode = .date
            
            //set Date picker bounds
            myDatePicker.minimumDate = Date()
            textField.inputView = myDatePicker
            myDatePicker.addTarget(self, action: #selector(setSelectedDate(sender: )), for: .valueChanged) //this sends the currently selected date at every instance that user pauses to the setSelectedDate(sender: UIDatePicker) method
        }
    }
    
    //this func sets each input passed to it to a string and sets the dueDateTextField to the resulting string
    func setSelectedDate(sender: UIDatePicker) {
        dueDateTextField?.text = thisDate.dateToString(inputDate: (sender.date))
    }
    
    //check if input money value is a valid number
    func isValidAmount( inputMoneyString: String? ) -> Bool {
        
        //confirm that the input value is not an empty string.
        guard inputMoneyString! != "" &&  inputMoneyString != nil else {
            return false
        }
        //conditions on money:
        //
        //1. the amount input by the user must be: 0.00 <= x <= 1,000,000,000.00 <- this range is set to adhere to our 13 char cell text space limit for money amounts
        //
        //2. the amount can only have digits 0-9 and can only have up to 1 "."
        let regexPatternGood = "\\d{1,9}\\.{0,1}\\d{0,2}"
        
        //this .range() method takes a regex pattern and returns the first instance of a matching string.
        //As long as the .range() function does not return nil (no match) then any match will return true.
        let regexCheck1:Bool = inputMoneyString!.range(of: regexPatternGood, options: .regularExpression, range: nil, locale: nil) != nil
        
        //char sets to test against
        let nonDigitChars = CharacterSet.letters
        let digitChars = CharacterSet.decimalDigits
        let decimalChar = "."
        
        //counters
        var numDecimalPoints = 0
        var numNonDigitChars = 0
        var numDigitsChars = 0
        let totalCharInString = inputMoneyString?.count
        var regexCheck2 = true
        for indexChar in (inputMoneyString?.unicodeScalars)! {
            
            if indexChar == "." {
                numDecimalPoints += 1
            } else if digitChars.contains(indexChar) {
                numDigitsChars += 1
            } else {
                return false //this is when we find any char that is not a digit or decimal point
            }
        }
        
        //if number of "." chars in string is more than 1 this string is not valid
        //
        //if number of digit chars in string is more than 11 this string is not valid
        //
        //if total number of chars in string is more than 12 this string is not valid
        if numDecimalPoints > 1 || numDigitsChars > 11 || totalCharInString! > 12 {
            regexCheck2 = false
        }
        
        if regexCheck1 && regexCheck2 {
            let testIfAmountIsNotTooBigOrTooSmall = Double(inputMoneyString!) as? Double
            
            if testIfAmountIsNotTooBigOrTooSmall! < 1000000000.00 {
            } else {
                print("Error: input amount is too big")
                return false
            }
            
            if testIfAmountIsNotTooBigOrTooSmall! > 0.00 {
                print ("-----> input amount is not too small")
            } else {
                print("Error: input amount is too small")
                return false
            }
            return true
        }
        return false
    }
    
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
}



























