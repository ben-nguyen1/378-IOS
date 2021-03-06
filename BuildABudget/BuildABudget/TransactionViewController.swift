//
//  TransactionViewController.swift
//  BuildABudget
//
//  Created by chris on 11/28/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import Foundation
import UIKit

protocol ExportDelegate: class {
    func exportMyData( callingUIViewController: UIViewController)
}

protocol ReminderDelegate: class {
    func createBudgetCalendar( callingUIViewController: UIViewController )
    func deleteBudgetCalendar( callingUIViewController: UIViewController )
}

class TransactionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let TransactionRetrieval = MyTransaction()
    var transactions: [MyTransaction]  = []
    let dateConverter = MyDate()
    let transactionAccess = AccessService.access
    let transactionAgent = MyTransaction.agent
    
    
    var moneyValidator = BudgetViewController.bc
    let exporter = Export.transferAgent
    weak var delegate: ExportDelegate?
    weak var reminderDelegate: ReminderDelegate?
    
    @IBOutlet weak var transactionTextField: UITextField!
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var transactionTable: UITableView!

    @IBAction func receivedClicked(_ sender: Any) {
        addNewTransaction(isIncome: true)
        updateTransactions()
    }

    @IBAction func exportButton(_ sender: Any) {
        let thisVC:UIViewController = self
        exporter.exportMyData( callingUIViewController: thisVC)
    }
    
    func addNewTransaction(isIncome: Bool) {
        self.transactionTextField.layer.borderWidth = 0.0

        guard let costTextField = self.transactionTextField.text, self.moneyValidator.isValidAmount(inputMoneyString: (self.transactionTextField.text)! )  else {
            self.transactionTextField.layer.borderColor = UIColor.red.cgColor
            self.transactionTextField.layer.borderWidth = 1.0
            return
        }
        let date = Date()
        let datePaidOff = Date()//dateConverter.setToYesterday(today: Date())
        
        let newTransaction = MyTransaction.create(iDes: "Trans-\(date.description(with: nil))",
                                                  iIniDate: Date(),
                                                  iDueDate: date,
                                                  iDatePaidOff: datePaidOff,
                                                  iTotalDue: (costTextField as NSString).doubleValue,
                                                  iIsReoccuring: false,
                                                  iIsIncome: isIncome,
                                                  iLinkedToGoal: "", //check if this is correct
                                                  iReminderID: "",
                                                  createNewReminder: true,
                                                  callingVC: self)
        
        transactionAccess.saveTransaction(input: newTransaction)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionTableCell")! as! TransactionTableViewCell
        if (indexPath.row == 0) {
            cell.costLabel.text = "Cost"
            cell.dateLabel.text = "Date"
            cell.itemLabel.text = "Item"
        } else {
            let index = indexPath.row - 1
            let currTrans = transactions[index]
            
            cell.costLabel.text = "\(Account.currency()) \(transactionAgent.getFormattedAmount(inputAmount: currTrans.totalDue) )"
            if (currTrans.isIncome) {
                cell.costLabel.textColor = UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)
            } else {
                cell.costLabel.textColor = UIColor.red
            }
            
            if (currTrans.desciption.count < 8) {
                cell.itemLabel!.text = currTrans.desciption
            } else {
                var maxIndex = 15
                if currTrans.desciption.count < maxIndex {
                    maxIndex = currTrans.desciption.count
                }
                let tempindex = currTrans.desciption.index(currTrans.desciption.startIndex, offsetBy: maxIndex)
                cell.itemLabel!.text = currTrans.desciption.substring(to: tempindex) + "..."
            }
            cell.dateLabel.text = dateConverter.shortDateToString(inputDate: currTrans.datePaidOff)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != 0
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { action, index in
            
            if (self.transactions[index.row - 1]).linkedToGoal != "" {
                let original = MyTransaction.agent.findMyTransactionLinkedToMyGoal( inputDescription: self.transactions[index.row - 1].linkedToGoal )
                original.isReoccuring = true
                self.transactionAccess.deleteTransaction(input: original)
                original.dueDate = self.dateConverter.getDateXNumDaysFromNow(inputStartDate: original.dueDate, inputXNumDays: -30) //may want to change the static 30 days input to reflect varying month lengths
               
                self.transactionAccess.saveTransaction(input: original)
            }
            
            self.transactionAccess.deleteTransaction(input: self.transactions[index.row - 1])
            self.updateTransactions()
        }
        delete.backgroundColor = UIColor.red
        return [delete]
    }

    func updateTransactions() {
        
        transactions = TransactionRetrieval.getAllNonReoccuringTransactions()
        
        var amount: Double = 0.0
        for i in 0..<transactions.count {
            if dateConverter.dateIsInThisMonth(inputDate: transactions[i].datePaidOff ) &&  transactions[i].isReoccuring == false { //this makes sure that we only use transactions which occured in this calendar month to calculate the amount remainning
                if transactions[i].isIncome {
                    amount += transactions[i].totalDue
                } else {
                    amount -= transactions[i].totalDue
                }
            }
        }
        let amountString = transactionAgent.getFormattedAmount(inputAmount: amount)
        self.amountLabel.text = "\(Account.currency()) \(amountString)"
        if (amount >= 0) {
            amountLabel.textColor = UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)
        } else {
            amountLabel.textColor = UIColor.red
        }
        
        var tempList = transactions
        self.transactions = tempList.sorted(by: { $0.datePaidOff > $1.datePaidOff } )
        self.transactionTable.reloadData()
        self.transactionTable.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTransactions()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transactionTable.dataSource = self
        transactionTable.delegate = self
        transactionTextField.keyboardType = UIKeyboardType.decimalPad
        updateTransactions()
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if (identifier == "transactionGoals") {
            guard let costTextField = self.transactionTextField.text, self.moneyValidator.isValidAmount(inputMoneyString: (self.transactionTextField.text)! )  else {
                self.transactionTextField.layer.borderColor = UIColor.red.cgColor
                self.transactionTextField.layer.borderWidth = 1.0
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.transactionTextField.layer.borderWidth = 0.0
        if (segue.identifier! == "transactionGoals") {
            let destNav = segue.destination as! UINavigationController
            let destController = destNav.viewControllers.first as! TransactionGoalTableViewController
            destController.value = Double(self.transactionTextField.text!)
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}


