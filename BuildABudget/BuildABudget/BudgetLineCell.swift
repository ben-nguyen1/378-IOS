//
//  TransactionCell.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class BudgetLineCell: UITableViewCell {
    
    @IBOutlet weak var itemName: UILabel!
    
    @IBOutlet weak var dueDate: UILabel!
    
    @IBOutlet weak var amount: UILabel!
    
   
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(inputName: String, inputDate: String, inputAmount: String) {
        itemName.text = inputName
        dueDate.text = inputDate
        amount.text = inputAmount
    }
    
}
