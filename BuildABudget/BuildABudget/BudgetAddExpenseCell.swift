//
//  BudgetAddExpenseCell.swift
//  BuildABudget
//
//  Created by chris on 10/26/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class BudgetAddExpenseCell: UITableViewCell {
    
    var inViewTable: Int = 0

    var delegate: ShowAlertProtocol?
    
    @IBAction func addExpense(_ sender: Any) {
        self.delegate?.launchAlertWindow(tableValueInput: inViewTable)
    }
    /*
    @IBAction func addButton(_ sender: Any) {
        self.delegate?.launchAlertWindow(tableValueInput: inViewTable)
    }
 */
    
   
     override func awakeFromNib() {
     super.awakeFromNib()
     }
     
     override func setSelected(_ selected: Bool, animated: Bool) {
     super.setSelected(selected, animated: animated)
     }
    
}
