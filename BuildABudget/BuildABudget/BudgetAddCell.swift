//
//  AddCell.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
import UIKit

class BudgetAddCell: UITableViewCell {
    
    var inViewTable: Int = 0
    let BudgetAddCellAccess = AccessService.access
    
    //UIAlert field vars
    //var descriptionTextField: UITextField? = nil
    //var dueDateTextField: UITextField? = nil
    //var totalDueTextField: UITextField? = nil //Double? = nil
    
    //Delegate that enables us to launch AlertWindows
    var delegate: ShowAlertProtocol?
    
    @IBAction func addButton(_ sender: Any) {

        self.delegate?.launchAlertWindow(tableValueInput: inViewTable)
    }
        


/*
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
 */
}

