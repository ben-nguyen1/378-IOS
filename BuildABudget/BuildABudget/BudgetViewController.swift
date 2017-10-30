//
//  BudgetViewController.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//

import UIKit



class BudgetViewController: UIViewController, UITableViewDataSource, AddBudgetLineProtocol {
   
    @IBOutlet weak var incomeTable: UITableView! //has attribute .tag = 111
    @IBOutlet weak var expenseTable: UITableView! //has attribute .tag = 222
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    
    fileprivate var incomeList: [MyTransaction] = []
    fileprivate var expenseList: [MyTransaction] = []
    fileprivate var thisBudget: MyBudget? = nil
    
    //UIAlert field vars
    var descriptionTextField: UITextField? = nil
    var dueDateTextField: UITextField? = nil
    var totalDueTextField: UITextField? = nil //Double? = nil
    
    //var with ability to interface with the coreData storage methods
    var BudgetAccess = AccessService.access
    
    //var delegate
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        thisBudget = BudgetAccess.getBudget(index: 0) //for right now it is hard coded to only get the first budget, we might allow users to save multiple budgets later on.
        incomeList = (thisBudget?.allIncome)!
        expenseList = (thisBudget?.allExpenses)!
    }
    
    
    //return number of rows for a specific tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if tableView.tag == 111{//incomeTable
            return incomeList.count + 1
        }
        else if tableView.tag == 222{//expenseTable
            return expenseList.count + 1
        }
        else {
            return 0 //catches tableview tags that are not incomeTable or expenseTable tags
        }
    }
    
    //populate each table with TableViewCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        
        if tableView.tag == 111{//incomeTable
            
            if (indexPath.row < (incomeList.count - 1)){//adding a BudgetLineCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetLineCell", for: indexPath) as! BudgetLineCell
                //set up the cell
                cell.config(inputName: incomeList[indexPath.item].desciption, inputDate: incomeList[indexPath.item].dueDate.description, inputAmount: incomeList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
                cell.inViewTable = 111
                return cell
            }
            else {//adding a BudgetAddCell, since this must be the last index
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetAddCell", for: indexPath) as! BudgetAddIncomeCell
                cell.inViewTable = 111
                cell.addBudgetLineDelegate = self
                return cell
            }
        }
        else {//expenseTable
            
            if (indexPath.row < (expenseList.count - 1)){//adding a BudgetLineCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetLineCell", for: indexPath) as! BudgetLineCell
                //set up the cell
                cell.config(inputName: expenseList[indexPath.item].desciption, inputDate: expenseList[indexPath.item].dueDate.description, inputAmount: expenseList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
                cell.inViewTable = 222
                return cell
            }
            else {//adding a BudgetAddCell, since this must be the last index
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetAddExpenseCell", for: indexPath) as! BudgetAddExpenseCell
                cell.inViewTable = 222
                return cell
            }
        }
        
    }
    
    
    func launchAlertWindow(tableValueInput: Int) {
        
        var alertWindowTitle:   String = ""
        var description:        String = ""
        var dueDate:            Date? = nil
        var totalDue:           Double = 0.0
        var isIncome:           Bool = false //only changed if add button from incomeTable is pressed
        
        if tableValueInput == 111 {// 111 means we are in the incomeTable
            alertWindowTitle = "New Monthly Income"
            isIncome = true
        }
        else {// this means that our inViewTable tag is 222 and we are in the expenseTable
            alertWindowTitle = "New Monthly Expense"
        }
        
        //set the AlertWindow's title and instruction message to user
        let newBudgetLineInputWindow = UIAlertController(title: alertWindowTitle, message: "Fill out all fields", preferredStyle: .alert)
        
        
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { (action: UIAlertAction!) -> Void in
            
            //grab all the data from the alert window's text fields
            guard let descriptionTextField = self.descriptionTextField?.text else { return }
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
           // print(">>>dateToString = \(testDateToString)\n")
            
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
        
        
        //do not change the order of these three .addTextFields
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            self.totalDueTextField = textField
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 01/09/2017"
            self.dueDateTextField = textField
        }
        
        
        //add the buttons to the Alert window
        newBudgetLineInputWindow.addAction(saveAction)
        newBudgetLineInputWindow.addAction(cancelAction)
        
        //display the alert window on the screen
        present(newBudgetLineInputWindow, animated: true, completion: nil)
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeTable.dataSource = self
        expenseTable.dataSource = self
        navigationItem.title = "Budget"
        print("IN BUDGET")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    
    
    
}//end of BudgetViewController class



























