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

    override func viewDidLoad() {
        super.viewDidLoad()
        unpaidTableView.dataSource = self
        
        // Do any additional setup after loading the view.
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
            return 1 //TODO: return number of unpaid cells
        } else {
            return 1 //TODO: return number of paid cells
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if (tableView == unpaidTableView) { //TODO: replace dummy values in each if statement
            let cell = tableView.dequeueReusableCell(withIdentifier: "unpaidCell")!
            cell.textLabel!.text = "BONELESS PIZZA"
            cell.detailTextLabel!.text = "$45"
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "paidCell") as! ChecklistPaidTableViewCell
            cell.amountLabel.text = "$2017"
            cell.dateLabel!.text = "10/10"
            cell.expenseLabel.text = "Candles"
            return cell
        }
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
