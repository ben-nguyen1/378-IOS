//
//  AddCell.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
import UIKit

protocol BudgetAddIncomeProtocol{
    
    func launchAlertWindow(tableValueInput: Int)//tableValueInput: Int
}

class BudgetAddIncomeCell: UITableViewCell {
    
    var inViewTable: Int = 0 //default value is 0 -> this gets reset in BudgetViewController func tableView 
    var incomeDelegate: BudgetAddIncomeProtocol!
    
  
    @IBAction func addIncomeButton(_ sender: Any) {
        print("add income")
        incomeDelegate.launchAlertWindow(tableValueInput: inViewTable)//tableValueInput: inViewTable
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}









