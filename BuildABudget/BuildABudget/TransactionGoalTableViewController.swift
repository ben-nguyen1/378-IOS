//
//  TransactionGoalTableViewController.swift
//  BuildABudget
//
//  Created by Nicholas Cobb on 11/30/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class TransactionGoalTableViewController: UITableViewController {
    var GoalsAccess = AccessService.access
    var goalsList: [MyGoal] = []
    var value: Double?

    @IBAction func continueNoContribution(_ sender: Any) {
        addNewTransaction(connectedGoal: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        GoalsAccess.retreiveAllGoals() //retrieve all MyGoal objects from coreData to AccessService class array
        goalsList = [] //reset this array to the empty set
        
        //read all goals from the AccessService goals[NSManagedObject] array into this class' goalsList[MyGoal]
        let limit = GoalsAccess.totalGoals()
        for i in 0..<limit {
            let currentGoalRecord = GoalsAccess.getGoal(index: i)
            if currentGoalRecord.getRemainingAmount() > 0 { //do not allow users to apply funds to goals that are completed
                goalsList.append( currentGoalRecord )
            }
        }
        //print("TEST: value = \(value)")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return goalsList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "transactionGoalCell", for: indexPath)

        cell.detailTextLabel?.text = goalsList[indexPath.row].desciption
        cell.textLabel?.text = goalsList[indexPath.row].getProgressString()

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        addNewTransaction(connectedGoal: goalsList[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
    
    func addNewTransaction(connectedGoal: MyGoal?) {
        let date = Date()
        //let newTransaction = MyTransaction(description: "Trans-\(date.description(with: nil))", dueDate: date, totalDue: value!, isReoccuring: false, isIncome: false)
        //newTransaction.datePaidOff = date
        let newTransaction = MyTransaction.create(  iDes: "Trans-\(date.description(with: nil))",
                                                    iIniDate: date,
                                                    iDueDate: date,
                                                    iDatePaidOff: date,
                                                    iTotalDue: value!,
                                                    iIsReoccuring: false, //set to false to indicate that we will only set a NON-reoccuring calendar event
                                                    iIsIncome: false,
                                                    iLinkedToGoal: "", //while this MyTransaction is being applied to a MyGoal object it is not being set as a reoccuring payment from the GoalsConfigViewController
                                                    iReminderID: "",
                                                    createNewReminder: true, //set to true to allow them to keep a record of when they paid this MyTransaction on the BuildABudgetCalendar
                                                    callingVC: self)
        
        if connectedGoal != nil {
            
            //create an identitical MyGoal object and apply the funds to it, then delete the original
            let newGoal:MyGoal = connectedGoal!.setEqualToGoal(oldGoal: connectedGoal!)

            if newGoal.getRemainingAmount() < value! {
                newGoal.allContributions += newGoal.getRemainingAmount() //if we are trying to apply more funds than amount remaining then only apply the amount that remains toward the goal balance
            } else {
                newGoal.allContributions += value!
            }
            
            let today = MyDate.dateConverter.shortDateToString(inputDate: Date())
            newTransaction.desciption = "\(newGoal.desciption)-\(today)"
            
            GoalsAccess.saveTransaction(input: newTransaction)
            GoalsAccess.deleteGoal(input: connectedGoal!) //deleted the old goal
            GoalsAccess.saveGoal(input: newGoal) //saved a new copy of the old goal with the allContributions attribute increased by the amount of var value
            
        } else {
            GoalsAccess.saveTransaction(input: newTransaction)
        }
    }
}
