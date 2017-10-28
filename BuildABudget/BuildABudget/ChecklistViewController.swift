//
//  ChecklistViewController.swift
//  BuildABudget
//
//  Created by Nicholas Cobb on 10/25/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class ChecklistViewController: UIViewController, UITableViewDataSource {
    @IBOutlet weak var unpaidTableView: UITableView!
    @IBOutlet weak var paidTableView: UITableView!
    
    // Var with ability to interface with the coreData storage methods
    var ChecklistAccess = AccessService.access
    var unpaidItems: [MyTransaction] = []
    var paidItems: [MyTransaction] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        unpaidTableView.dataSource = self
        paidTableView.dataSource = self
        
        
        ChecklistAccess.retreiveAllTransactions()
        var i = 0
        while (i < ChecklistAccess.totalTransactions()) {
            let currTransaction = ChecklistAccess.getTransaction(index: i)
            if (currTransaction.isReoccuring) {
                if (currTransaction.isPastDue()) {
                    paidItems.append(currTransaction)
                } else {
                    paidItems.append(currTransaction)
                }
            }
            i += 1
        }
    }
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (tableView == unpaidTableView) {
            return unpaidItems.count
        } else if (tableView == paidTableView) {
            return paidItems.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if (tableView == self.unpaidTableView) { //TODO: replace dummy values with actual array values.
            cell = tableView.dequeueReusableCell(withIdentifier: "unpaidCell")!
            cell!.textLabel!.text = "BONELESS PIZZA"
            cell!.detailTextLabel!.text = "$45"
        } else if (tableView == self.paidTableView) {
            let newCell = tableView.dequeueReusableCell(withIdentifier: "paidCell") as! ChecklistPaidTableViewCell
            newCell.amountLabel.text = "$2017"
            newCell.dateLabel!.text = "10/10"
            newCell.expenseLabel.text = "Candles"
            return newCell
        }
        return cell!
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
