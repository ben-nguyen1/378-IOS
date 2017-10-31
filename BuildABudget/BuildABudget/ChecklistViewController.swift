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
            if (currTransaction.isReoccuring) {
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
            print("paid button tapped \(index.row)")
            //TODO: implement paid
        }
        paid.backgroundColor = UIColor.green
        
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            print("delete button tapped \(index.row)")
            //TODO: implement delete
        }
        paid.backgroundColor = UIColor.red
        
        return [paid, delete]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return tableView == self.unpaidTableView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == self.unpaidTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "unpaidCell")! as! ChecklistUnpaidTableViewCell
            let currItem = unpaidItems[indexPath.row]

            cell.expenseLabel!.text = currItem.desciption
            cell.amountLabel!.text = "\(currItem.totalDue)"
            return cell
        } else {
            let newCell = tableView.dequeueReusableCell(withIdentifier: "paidCell") as! ChecklistPaidTableViewCell
            let currItem = paidItems[indexPath.row]

            newCell.amountLabel.text = "\(currItem.totalDue)"
            newCell.dateLabel!.text = dateConverter.dateToString(inputDate: currItem.datePaidOff)
            newCell.expenseLabel.text = currItem.desciption
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
            dueDateTextField = textField
            dueDateTextField!.placeholder = "Checklist Item Due Date (mm/dd/yyyy)"
        }
        
        alertController.addTextField { (textField) -> Void in
            costTextField = textField
            costTextField!.placeholder = "Checklist Item Cost"
        }
        
        let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) -> Void in
            print("Ok Pressed; checklist")
            let transactionDate = self.dateConverter.stringToDate(inputString: dueDateTextField!.text!)
            let cost = Double(costTextField!.text!)
            
            if (transactionDate < Date() && cost != nil) {
                //handle error
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
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
