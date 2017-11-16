//
//  OverviewGoalsTableViewCell.swift
//  BuildABudget
//
//  Created by Nicholas Cobb on 11/15/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class OverviewGoalsTableViewCell: UITableViewCell {
    @IBOutlet weak var goalNameLabel: UILabel!
    @IBOutlet weak var progressLabel: UILabel!
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
