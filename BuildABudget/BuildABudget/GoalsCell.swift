//
//  GoalsCell.swift
//  BuildABudget
//
//  Created by chris on 11/4/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class GoalsCell: UITableViewCell {
    
    
    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var estimatedCompletionDate: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var goalConfigButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    
    
    //cell.config(inputName: incomeList[indexPath.item].desciption, inputDate: shortDate, inputAmount: incomeList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.

    func config( inputName: String, inputProgress: Float, inputEstimatedCompletionDateString: String) {
        
        print("\n----------------------------------------")
        print("INFO FROM GOALSCELL config():")
        print("inputName = \(inputName)")
        print("inputProgress = \(inputProgress)")
        print("inputEstimatedCompletionDateString = \(inputEstimatedCompletionDateString)")
        print("----------------------------------------\n")
        
        
        goalName.text = inputName //Unexpectedly found nil while unwrapping an Optional Value
        
        estimatedCompletionDate.text = inputEstimatedCompletionDateString
        
        //setup the progressBar
        //progressBar = UIProgressView(progressViewStyle: UIProgressViewStyle.default)
        progressBar.progressTintColor = UIColor.brown //setupProgressBar(inputPercentProgress: inputProgress)
        progressBar.progress = inputProgress
        
    }
    
    
    //sets the progress bar color based on the percent progress toward completion
    func setupProgressBar(inputPercentProgress:Float) -> UIColor{
        
        if inputPercentProgress < 33.4 {
            return UIColor.red
        }
        else if inputPercentProgress > 33.3 && inputPercentProgress < 66.4{
            return UIColor.yellow
        }
        else {
            return UIColor.green
        }
        
    }
    
}
















