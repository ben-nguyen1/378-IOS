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
    
    
    
    @IBOutlet weak var percentLable: UILabel!
    @IBOutlet weak var startDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    

    
    
    //cell.config(inputName: incomeList[indexPath.item].desciption, inputDate: shortDate, inputAmount: incomeList[indexPath.item].totalDue.description) //may need to chnage how to parameters dueDate and amount are converted to string.

    func config( inputName: String, inputProgress: Float, inputEstimatedCompletionDateString: String, inputStartDateString: String) {
        
        /* //DIAGNOSTIC CODE
        print("\n----------------------------------------")
        print("INFO FROM GOALSCELL config():")
        print("inputName = \(inputName)")
        print("inputProgress = \(inputProgress)")
        print("inputEstimatedCompletionDateString = \(inputEstimatedCompletionDateString)")
        print("----------------------------------------\n")
        */
        
        goalName.text = inputName //Unexpectedly found nil while unwrapping an Optional Value
        estimatedCompletionDate.text = inputEstimatedCompletionDateString
        percentLable.text = String(inputProgress)
        startDateLabel.text = inputStartDateString
        
        //setup the progressBar
        progressBar.progressTintColor = setupProgressBar(inputPercentProgress: (inputProgress * 0.1) * 0.1)
        progressBar.trackTintColor = UIColor.orange
        progressBar.setProgress( (inputProgress * 0.1) * 0.1, animated: true)
        
        //[self.myTableViewCell.contentView.layer setBorderColor:[UIColor redColor].CGColor];
        self.contentView.layer
        //[self.myTableViewCell.contentView.layer setBorderWidth:1.0f];
        
        /*//DIAGNOSTIC CODE
        if inputName == "test" {
        progressBar.progressTintColor = UIColor.orange //setupProgressBar(inputPercentProgress: 33.3) //inputProgress
        progressBar.trackTintColor = setupProgressBar(inputPercentProgress: 0.9)//UIColor.white
        progressBar.setProgress(33.3, animated: true)//inputProgress
        }
        else {
            progressBar.progressTintColor = setupProgressBar(inputPercentProgress: 0.4) //inputProgress
            progressBar.trackTintColor = UIColor.orange //setupProgressBar(inputPercentProgress: inputProgress)//UIColor.white
            progressBar.setProgress(10.0, animated: true)//inputProgress
        }
        */
        
    }
    
    
    //sets the progress bar color based on the percent progress toward completion
    func setupProgressBar(inputPercentProgress:Float) -> UIColor{
        
        if inputPercentProgress <= 0.3 {
            return UIColor.red
        }
        else if inputPercentProgress > 0.3 && inputPercentProgress <= 0.6{
            return UIColor.yellow
        }
        else {
            return UIColor.green
        }
        
    }
    
}
















