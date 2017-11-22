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
    
    func config( inputName: String, inputProgress: Float, inputProgressString: String, inputEstimatedCompletionDateString: String, inputStartDateString: String) {
        
        goalName.text = inputName //Unexpectedly found nil while unwrapping an Optional Value
        estimatedCompletionDate.text = inputEstimatedCompletionDateString
        percentLable.text = inputProgressString + " %"
        startDateLabel.text = inputStartDateString
        
        //setup the progressBar
        progressBar.progressTintColor = setupProgressBar(inputPercentProgress: (inputProgress * 0.1) * 0.1)
        progressBar.trackTintColor = UIColor.orange
        progressBar.setProgress( (inputProgress * 0.1) * 0.1, animated: true)
        self.contentView.layer
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
















