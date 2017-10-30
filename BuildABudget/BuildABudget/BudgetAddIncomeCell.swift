//
//  AddCell.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
import UIKit

protocol AddBudgetLineProtocol{
    
    func launchAlertWindow(tableValueInput: Int)//tableValueInput: Int
}

class BudgetAddIncomeCell: UITableViewCell {
    
    var inViewTable: Int = 0
    var addBudgetLineDelegate: AddBudgetLineProtocol!
    
  
    @IBAction func addIncomeButton(_ sender: Any) {
        print("add income")
        addBudgetLineDelegate.launchAlertWindow(tableValueInput: inViewTable)//tableValueInput: inViewTable
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}









