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
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetAddCell", for: indexPath) as! BudgetAddCell
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetAddExpenseCell", for: indexPath) as! BudgetAddCell
                cell.inViewTable = 222
                return cell
            }
        }
        
    }
    
    
    func launchAlertWindow(tableValueInput: Int) {
        //print("MADE PROTOCOL WORK!!")
        //print("tableValue = \(tableValueInput)")
        
        //vars
        
        var alertWindowTitle:   String = ""
        var description:        String = ""
        var initialInputDate:   Date = Date()
        var dueDate:            Date? = nil
        var totalDue:           Double = 0.0
        var isReoccuring:       Bool = true //by default since this MyTransaction object is generated in the Budget View Controller isReoccuring must be yes.
        
        var isIncome:           Bool = false //only changed if add button from incomeTable is pressed
        var todaysDate = MyDate()

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
            
            /*
             
             guard let descriptionTextField = self.descriptionTextField?.text else { return }
             
             description = descriptionTextField
             
             guard let dueDateTextField = self.dueDateTextField?.text else { return }
             
             dueDate = thisDate.makeDate(inputDay: Int:(), inputMonth: <#T##Int#>, inputYear: <#T##Int#>, inputMinute: <#T##Int#>, inputHour: <#T##Int#>)
             
             guard let totalDueTextField = self.totalDueTextField?.text else { return }
             
             
             
             //PersistenceService.shared.savePerson(name: nameTextField, age: ageTextField)
             
             var newTransaction =
             
             BudgetAccess.
             
             //self.tableView.reloadData()  // causes the table data source protocol methods to execute
             
             */
            
            print("MADE IT HERE")
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) {
            (action: UIAlertAction!) -> Void in
        }
        
        
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Item Description"
            self.descriptionTextField = textField
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Amount ex: 32.49"
            textField.keyboardType = .numberPad
            self.dueDateTextField = textField
            
        }
        
        newBudgetLineInputWindow.addTextField { (textField) -> Void in
            textField.placeholder = "Due Date ex: 1/9/2017"
            textField.keyboardType = .numberPad
            self.totalDueTextField = textField
            
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



























