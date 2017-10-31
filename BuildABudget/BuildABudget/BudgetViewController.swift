//
//  BudgetViewController.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//

import UIKit



class BudgetViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, BudgetAddIncomeProtocol, BudgetAddExpenseProtocol {
   
    @IBOutlet weak var incomeTable: UITableView! //has attribute .tag = 111
    @IBOutlet weak var expenseTable: UITableView! //has attribute .tag = 222
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    
    fileprivate var incomeList: [MyTransaction] = []
    fileprivate var expenseList: [MyTransaction] = []
    fileprivate var thisBudget: MyBudget? = nil
    
    var incomeTotal:Double = 0.0
    var expenseTotal:Double = 0.0
    
    //UIAlert field vars
    var descriptionTextField: UITextField? = nil
    var dueDateTextField: UITextField? = nil
    var totalDueTextField: UITextField? = nil //Double? = nil
    
    //var with ability to interface with the coreData storage methods
    var BudgetAccess = AccessService.access
    let thisDate = MyDate.dateConverter
    
    //var delegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        thisBudget = BudgetAccess.getBudget(index: 0) //for right now it is hard coded to only get the first budget, we might allow users to save multiple budgets later on.
        //incomeList = (thisBudget?.allIncome)!
        //expenseList = (thisBudget?.allExpenses)!
        update()
    }
    
    
    //return number of rows for a specific tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView.tag == 111{//incomeTable
            print("incomeList = \(incomeList.count)")
            return incomeList.count
        }
        else if tableView.tag == 222{//expenseTable
            print("expenseList = \(expenseList.count)")
            return expenseList.count
        }
        else {
            return 0 //catches tableview tags that are not incomeTable or expenseTable tags
        }
    }
    
    
    
    
    //populate each table with TableViewCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if (tableView == self.incomeTable){//tableView.tag == 111    incomeTable
            if (indexPath.row < (incomeList.count)){//adding a BudgetLineCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetLineCell", for: indexPath) as! BudgetLineCell
                //set up the cell
                let shortDate = thisDate.shortDateToString(inputDate: (incomeList[indexPath.item].dueDate) )
                //cell.config(inputName: incomeList[indexPath.item].desciption, inputDate: incomeList[indexPath.item].dueDate.description, inputAmount: incomeList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
                cell.config(inputName: incomeList[indexPath.item].desciption, inputDate: shortDate, inputAmount: incomeList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
                
                
                cell.inViewTable = 111
                return cell
            }
            else {//adding a BudgetAddIncomeCell, since this must be the last index
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetAddIncomeCell", for: indexPath) as! BudgetAddIncomeCell
                cell.inViewTable = 111
                cell.incomeDelegate = self
                return cell
            }
        }
        else {//expenseTable
            
            if (indexPath.row < expenseList.count ){//adding a BudgetLineCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetLineCell", for: indexPath) as! BudgetLineCell
                //set up the cell
                cell.config(inputName: expenseList[indexPath.item].desciption, inputDate: expenseList[indexPath.item].dueDate.description, inputAmount: expenseList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
                cell.inViewTable = 222
                return cell
            }
            else {//adding a BudgetAddExpenseCell, since this must be the last index
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetAddExpenseCell", for: indexPath) as! BudgetAddExpenseCell
                cell.inViewTable = 222
                cell.expenseDelegate = self
                return cell
            }
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
            //self.descriptionTextField?.layer.borderColor = (UIColor.red).cgColor <--- these two lines are how we let user know they goofed.
            //self.descriptionTextField?.layer.borderWidth = 1.0
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
            
            
            
            //while <--- we will implement a while loop here to catch bad input
            
            
            //grab all the data from the alert window's text fields
            guard let descriptionTextField = self.descriptionTextField?.text, self.isValidDescription(input: (self.descriptionTextField?.text)!) else {
                print("<<<<<< HERE >>>>>")
                return }
            guard let totalDueTextField = self.totalDueTextField?.text else { return }
            guard let dueDateTextField = self.dueDateTextField?.text else { return }
            
            
            //set the data that we grabbed into local variables
            description = descriptionTextField
            dueDate = MyDate.dateConverter.stringToDate(inputString: dueDateTextField)
            totalDue = (totalDueTextField as NSString).doubleValue
            
            //check that Alert window is getting the correct input
            //print("\ndescriptionTextField = \(description)")
            //print("dueDateTextField = \(dueDate)")
            //print("totalDueTextField = \(totalDue)\n")
            //var testDateToString = MyDate.dateConverter.dateToString(inputDate: dueDate!)
            //print(">>>dateToString = \(testDateToString)\n")
            
            //Build the MyTransaction Object
            let newBudgetItem = MyTransaction.create( iDes: description,
                                                      iIniDate: Date(),
                                                      iDueDate: dueDate!,
                                                      iDatePaidOff: MyDate.dateConverter.setToYesterday(today: Date()),
                                                      iTotalDue: totalDue,
                                                      iIsReoccuring: true,
                                                      iIsIncome: isIncome)
            
            //save the MyTransaction Object to CoreData
            AccessService.access.saveTransaction(input: newBudgetItem)
          
            //reload the table so that it displays the newly added Transaction.
            //self.tableView.treloadData()  // causes the table data source protocol methods to execute
            
            print("\n\nFinished Saving a new BudgetLineItem")
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
        print("IN BUDGET")
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
        var limit = BudgetAccess.totalTransactions()
        for i in 0..<limit {
            let temp = BudgetAccess.getTransaction(index: i)
            if temp.isIncome {
                incomeList.append(temp)
                incomeTotal += temp.totalDue
                print("incomeTotal = \(incomeTotal)")
            }
            else {
                expenseList.append(temp)
                expenseTotal += temp.totalDue
                print("incomeTotal = \(incomeTotal)")
            }
        }
        
        
    }
    
    
    
}//end of BudgetViewController class



























