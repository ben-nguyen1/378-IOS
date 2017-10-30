//
//  BudgetAddExpenseCell.swift
//  BuildABudget
//
//  Created by chris on 10/26/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

protocol BudgetAddExpenseProtocol{
    
    func launchAlertWindow(tableValueInput: Int)//tableValueInput: Int
}

class BudgetAddExpenseCell: UITableViewCell {
    
    var inViewTable: Int = 0 //default value is 0 -> this gets reset in BudgetViewController func tableView 
    //var delegate: AddBudgetLineProtocol?
    var expenseDelegate: BudgetAddExpenseProtocol!
    
    
    
    @IBAction func addExpense(_ sender: Any) {
        print("addExpense")
        expenseDelegate.launchAlertWindow(tableValueInput: inViewTable)
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

