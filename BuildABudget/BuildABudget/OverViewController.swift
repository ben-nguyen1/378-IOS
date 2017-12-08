//
//  OverViewController.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 10/20/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
import UIKit

class OverViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var currency = Account.currency()
    var dateConverter = MyDate()
    var reminders: [MyTransaction] = []
    var goalsList: [MyGoal] = []
    
    @IBOutlet weak var budgetHeader: UILabel!
    @IBOutlet weak var welcomeText: UILabel!
    @IBOutlet weak var reminderTableView: UITableView!
    @IBOutlet weak var goalsTableView: UITableView!
    var accessService = AccessService.access
    let reminderAgent = Reminders.agent
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.currency = Account.currency()
        welcomeText.text = "Hello, \(Account.firstName())"
        reminderTableView.dataSource = self
        goalsTableView.dataSource = self
        reminderTableView.delegate = self
        goalsTableView.delegate = self
        self.navigationItem.setHidesBackButton(true, animated:true);
        self.title = "Overview"
        reminderAgent.checkAuthorization(callingUIViewController: self) //this prompts user to allow us to access the calendar
    }

    override func viewWillAppear(_ animated: Bool) {
        self.currency = Account.currency()
        super.viewWillAppear(animated)
        self.update()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == reminderTableView) {
            if (reminders.count < 4) {
                return reminders.count
            } else {
                return 4
            }
        } else if (tableView == goalsTableView) {
            if (goalsList.count < 4) {
                return goalsList.count
            } else {
                return 4
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == reminderTableView) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "overviewReminderCell")!
            cell.textLabel?.text = "Pay off: " + reminders[indexPath.row].desciption
            cell.detailTextLabel?.text = dateConverter.shortDateToString(inputDate: reminders[indexPath.row].dueDate)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "overviewGoalCell")! as! OverviewGoalsTableViewCell
            let goal = self.goalsList[indexPath.row]
            
            cell.dueDateLabel.text = dateConverter.dateToString(inputDate: goal.targetDate)
            cell.goalNameLabel.text = goal.desciption
            cell.progressLabel.text = goal.getProgressString() + " %"
            cell.progressBar.setProgress(goal.getProgress() * 0.01, animated: false)
            
            return cell
        }
    }
    
    func update() {
        self.updateGoals()
        self.updateReminders()
        self.updateBudgetValue()
        self.goalsTableView.reloadData()
        self.reminderTableView.reloadData()
    }
    
    func updateReminders() {
        reminders = []
        
        accessService.retreiveAllTransactions()
        var i = 0
        while (i < accessService.totalTransactions()) {
            let currTransaction = accessService.getTransaction(index: i)
            if (currTransaction.isReoccuring && !currTransaction.isIncome && !currTransaction.isPastDue()) {
                    reminders.append(currTransaction)
                
            }
            i += 1
        }
    }

    func updateGoals() {
        accessService.retreiveAllGoals()
        goalsList = []

        var limit = accessService.totalGoals()
        for i in 0..<limit {
            let currentGoalRecord = accessService.getGoal(index: i)
            goalsList.append(currentGoalRecord)
        }
    }
    
    func updateBudgetValue() {
        accessService.retreiveAllTransactions()//cause all transactions to be reloaded by CoreDate interface
        
        //set all lists and counters to 0
        var incomeList: [MyTransaction] = []
        var expenseList: [MyTransaction] = []
        var incomeTotal = 0.0
        var expenseTotal = 0.0
        
        var i = 0
        var limit = accessService.totalTransactions()
        for i in 0..<limit {
            let temp = accessService.getTransaction(index: i)
            if temp.isIncome {
                incomeList.append(temp)
                incomeTotal += temp.totalDue
            }
            else {
                expenseList.append(temp)
                expenseTotal += temp.totalDue
            }
        }
        
        if (incomeTotal - expenseTotal >= 0.0) {
            self.budgetHeader.text = String(format: "\(currency) %.2F", (incomeTotal - expenseTotal))
            self.budgetHeader.textColor = UIColor(red:0.32, green:0.64, blue:0.33, alpha:1.0)
        } else {
            self.budgetHeader.text = String(format: "\(currency) %.2F", (incomeTotal - expenseTotal))
            self.budgetHeader.textColor = UIColor.red
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
