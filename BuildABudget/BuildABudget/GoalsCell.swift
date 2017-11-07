//
//  GoalsCell.swift
//  BuildABudget
//
//  Created by chris on 11/4/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class GoalsCell: UITableViewCell {

    //class instanciations
    
    
    // UI elements
    @IBOutlet weak var goalName: UILabel!
    @IBOutlet weak var estimatedCompletionDate: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var goalConfigButton: UIButton!
    
    
    var progress:Float = 0.0
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func config(inputGoal:MyGoal) {
        goalName.text = inputGoal.desciption
        estimatedCompletionDate.text = inputGoal.tagetDateToString()
        progressBar.progressTintColor = setupProgressBar( inputPercentProgress: inputGoal.getProgress() )
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
















