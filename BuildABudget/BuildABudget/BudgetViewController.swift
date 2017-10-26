//
//  BudgetViewController.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//

import UIKit

class BudgetViewController: UIViewController, UITableViewDataSource {

    @IBOutlet weak var incomeTable: UITableView! //has attribute .tag = 111
    @IBOutlet weak var expenseTable: UITableView! //has attribute .tag = 222
    
    @IBOutlet weak var incomeLabel: UILabel!
    @IBOutlet weak var expenseLabel: UILabel!
    @IBOutlet weak var differenceLabel: UILabel!
    
    fileprivate var incomeList: [MyTransaction] = []
    fileprivate var expenseList: [MyTransaction] = []
    fileprivate var thisBudget: MyBudget? = nil
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        thisBudget = AccessService.access.getBudget(index: 0) //for right now it is hard coded to only get the first budget, we might allow users to save multiple budgets later on.
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
    
    //pupulate each table with TableViewCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        
        
        if tableView.tag == 111{//incomeTable
            
            if (indexPath.row < (incomeList.count - 1)){//adding a BudgetLineCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetLineCell", for: indexPath) as! BudgetLineCell
                //set up the cell
                cell.config(inputName: incomeList[indexPath.item].desciption, inputDate: incomeList[indexPath.item].dueDate.description, inputAmount: incomeList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
                return cell
            }
            else {//adding a BudgetAddCell, since this must be the last index
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetAddCell", for: indexPath) as! BudgetAddCell
                return cell
            }
        }
        else {//expenseTable
            
            if (indexPath.row < (expenseList.count - 1)){//adding a BudgetLineCell
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetLineCell", for: indexPath) as! BudgetLineCell
                //set up the cell
                cell.config(inputName: expenseList[indexPath.item].desciption, inputDate: expenseList[indexPath.item].dueDate.description, inputAmount: expenseList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.
                return cell
            }
            else {//adding a BudgetAddCell, since this must be the last index
                let cell = tableView.dequeueReusableCell(withIdentifier: "BudgetAddCell", for: indexPath) as! BudgetAddCell
                return cell
            }
        }
        
    }
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        incomeTable.dataSource = self
        expenseTable.dataSource = self
        navigationItem.title = "Budget"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
























