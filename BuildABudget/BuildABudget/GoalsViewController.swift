//
//  GoalsViewController.swift
//  BuildABudget
//
//  Created by chris on 11/4/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import UIKit

class GoalsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var goalsTable: UITableView!
    @IBOutlet weak var addGoalButton: UIButton!
    
    //var with ability to interface with the coreData storage methods
    var GoalsAccess = AccessService.access
    var goalsList: [MyGoal] = []
    
    
    
    //UIViewController functions
    override func viewDidLoad() {
        super.viewDidLoad()
        goalsTable.dataSource = self
        goalsTable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //populate each table with TableViewCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalsCell", for: indexPath) as! GoalsCell
        cell.config(inputGoal: goalsList[indexPath.item]) //pass the reference of the MyGoal object to the GoalsCell that will display it
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return goalsList.count
    }
    
    
    //get all goals and cause goalsTable to reload
    func update() {
    
        GoalsAccess.retreiveAllGoals() //retrieve all MyGoal objects from coreData to AccessService class array
        
        //read all goals from the AccessService goals[NSManagedObject] array into this class' goalsList[MyGoal]
        var limit = GoalsAccess.totalGoals()
        for i in 0..<limit {
            goalsList.append( GoalsAccess.getGoal(index: i) )
        }
        
        self.goalsTable.reloadData()//force the goalsTable to reload the GoalsCells it displays
    }
    
    
    
    
    
}



































