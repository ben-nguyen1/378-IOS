//
//  ChecklistViewController.swift
//  BuildABudget
//
//  Created by Nicholas Cobb on 10/25/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
import UIKit

class ChecklistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var unpaidTableView: UITableView!
    @IBOutlet weak var paidTableView: UITableView!
    
    // Var with ability to interface with the coreData storage methods
    var ChecklistAccess = AccessService.access
    
    var dateConverter = MyDate()
    var unpaidItems: [MyTransaction] = []
    var paidItems: [MyTransaction] = []

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
                    unpaidItems.append(currTransaction)
                }
            }
            i += 1
        }
        print(i)
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

    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let paid = UITableViewRowAction(style: .normal, title: "Paid") { action, index in
            let transactionToChange = self.unpaidItems[index.row]
            self.ChecklistAccess.deleteTransaction(input: transactionToChange)
            transactionToChange.datePaidOff = Date()
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
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView == self.unpaidTableView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.unpaidTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "unpaidCell")! as! ChecklistUnpaidTableViewCell
            let currItem = unpaidItems[indexPath.row]
            
            if (currItem.desciption.count < 8) {
                cell.expenseLabel!.text = currItem.desciption
            } else {
                let index = currItem.desciption.index(currItem.desciption.startIndex, offsetBy: 5)
                cell.expenseLabel!.text = currItem.desciption.substring(to: index) + "..."
            }
            cell.amountLabel!.text = "$\(currItem.totalDue)"
            cell.dueDateLabel.text = dateConverter.dateToString(inputDate: currItem.dueDate)
            return cell
        } else {
            let newCell = tableView.dequeueReusableCell(withIdentifier: "paidCell") as! ChecklistPaidTableViewCell
            let currItem = paidItems[indexPath.row]

            newCell.amountLabel.text = "$\(currItem.totalDue)"
            newCell.dateLabel!.text = dateConverter.dateToString(inputDate: currItem.datePaidOff)
            
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
        let alertController: UIAlertController = UIAlertController(title: "Add Checklist Expense", message: "Enter the details for the new checklist expense.", preferredStyle: UIAlertControllerStyle.alert)

        var descriptionTextField: UITextField? = nil
        var dueDateTextField: UITextField? = nil
        var costTextField: UITextField? = nil
        
        
        alertController.addTextField { (textField) -> Void in
            descriptionTextField = textField
            descriptionTextField!.placeholder = "Checklist Item Name"
        }
        
        alertController.addTextField { (textField) -> Void in
            costTextField = textField
            costTextField!.placeholder = "Checklist Item Cost"
            costTextField?.keyboardType = UIKeyboardType.decimalPad
        }
        
        alertController.addTextField { (textField) -> Void in
            dueDateTextField = textField
            dueDateTextField!.placeholder = "Checklist Item Due Date (mm/dd/yyyy)"
        }
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            print("Ok Pressed; checklist")
            let transactionDate = self.dateConverter.stringToDate(inputString: dueDateTextField!.text!)
            let cost = Double(costTextField!.text!)

            if (descriptionTextField!.text!.isEmpty) {
                let errorAlertController: UIAlertController = UIAlertController(title: "Invalid entry", message: "Please enter a non-empty description.", preferredStyle: UIAlertControllerStyle.alert)
                
                let errorOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
                    print("Ok Pressed; checklist error")
                }
                
                errorAlertController.addAction(errorOk)
                self.present(errorAlertController, animated: true, completion: nil)
            } else if (cost == nil) {
                let errorAlertController: UIAlertController = UIAlertController(title: "Invalid entry", message: "Please enter a valid cost", preferredStyle: UIAlertControllerStyle.alert)
                
                let errorOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
                    print("Ok Pressed; checklist error")
                }
                
                errorAlertController.addAction(errorOk)

                self.present(errorAlertController, animated: true, completion: nil)
            } else if (cost! < 0.0) {
                let errorAlertController: UIAlertController = UIAlertController(title: "Invalid entry", message: "Please enter a positive cost", preferredStyle: UIAlertControllerStyle.alert)
                
                let errorOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
                    print("Ok Pressed; checklist error")
                }
                
                errorAlertController.addAction(errorOk)
                
                self.present(errorAlertController, animated: true, completion: nil)
            } else if (transactionDate < self.dateConverter.setToYesterday(today: Date())) {
                let errorAlertController: UIAlertController = UIAlertController(title: "Invalid entry", message: "Please enter a date that is not in the past", preferredStyle: UIAlertControllerStyle.alert)
                
                let errorOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
                    print("Ok Pressed; checklist error")
                }
                
                errorAlertController.addAction(errorOk)
                
                self.present(errorAlertController, animated: true, completion: nil)
            } else if (transactionDate < Date()) {
                let errorAlertController: UIAlertController = UIAlertController(title: "Invalid entry", message: "Please enter a valid date", preferredStyle: UIAlertControllerStyle.alert)
                
                let errorOk = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default) { (action) -> Void in
                    print("Ok Pressed; checklist error")
                }
                
                errorAlertController.addAction(errorOk)
                
                self.present(errorAlertController, animated: true, completion: nil)
            } else {
                let newExpense = MyTransaction(description: descriptionTextField!.text!, dueDate: transactionDate, totalDue: cost!, isReoccuring: true, isIncome: false)

                self.ChecklistAccess.saveTransaction(input: newExpense)
                self.updateTables()
            }
        })
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action) -> Void in
            print("Cancel Pressed; checklist")
        }
        
        alertController.addAction(ok)
        alertController.addAction(cancel)

        present(alertController, animated: true, completion: nil)
    }
    
}
