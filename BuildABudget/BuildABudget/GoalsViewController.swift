//
//  GoalsViewController.swift
//  BuildABudget
//
//  Created by chris on 11/4/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
import UIKit

class GoalsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, EditGoalDelegate, DeleteGoalDelegate {

    @IBOutlet weak var goalsTable: UITableView!
    @IBOutlet weak var addGoalButton: UIButton!
    
    //var with ability to interface with the coreData storage methods
    var GoalsAccess = AccessService.access
    var goalsList: [MyGoal] = []
    let goalDate = MyDate()
    let reuseIdentifier = "GoalsCell"
    static let gvc = GoalsViewController()
    
    //UIViewController functions
    override func viewDidLoad() {
        print("\n>>>REACHED GOALSVC - viewDidLoad()")
        super.viewDidLoad()
        self.goalsTable.rowHeight = 75
        update()
        goalsTable.dataSource = self
        goalsTable.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("\n>>>REACHED GOALSVC - viewWillAppear()")
        self.goalsTable.rowHeight = 75
        update()
        goalsTable.dataSource = self
        goalsTable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //populate each table with TableViewCells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GoalsCell", for: indexPath) as! GoalsCell
        let goalAtIndex = goalsList[indexPath.item]
        
        //config( inputName: String, inputProgress: Float, inputEstimatedCompletionDate: Date)
        cell.config( inputName:                          goalAtIndex.desciption,
                     inputProgress:                      goalAtIndex.getProgress(),
                     inputProgressString:                goalAtIndex.getProgressString(),
                     inputEstimatedCompletionDateString: goalDate.dateToString(inputDate: ( goalAtIndex.getEstimatedCompletionDate() )),
                     inputStartDateString:               goalDate.dateToString(inputDate: ( goalAtIndex.startDate ) )
        )
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.goalsList.count
    }
    
    //get all goals and cause goalsTable to reload
    func update() {
    
        GoalsAccess.retreiveAllGoals() //retrieve all MyGoal objects from coreData to AccessService class array
        goalsList = [] //reset this array to the empty set
        
        //read all goals from the AccessService goals[NSManagedObject] array into this class' goalsList[MyGoal]
        let limit = GoalsAccess.totalGoals()
        for i in 0..<limit {
            let currentGoalRecord = GoalsAccess.getGoal(index: i)
            goalsList.append( currentGoalRecord )
        }
        self.goalsTable.reloadData()//force the goalsTable to reload the GoalsCells it displays
        print(">>>GOALSVC: finished updating the goalsList")
        print("goalsList count = \(goalsList.count) , AccessService goals count = \(GoalsAccess.totalGoals())\n")
    }
    
    func getSpecificGoal( goalName: String ) -> MyGoal{
        
        GoalsAccess.retreiveAllGoals() //retrieve all MyGoal objects from coreData to AccessService class array
        let limit = GoalsAccess.totalGoals()
        
        for i in 0..<limit {
            let currentGoalRecord = GoalsAccess.getGoal(index: i)
            if currentGoalRecord.desciption == goalName {
                return currentGoalRecord
            }
        }
        
        //if there is nothing to return
        return MyGoal() //this generic object has MyGoal.desciption set to "error" to indicate to calling method that there was no such goalName
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let existingGoal = segue.destination as! GoalsConfigViewController
        if let indexPath = self.goalsTable.indexPathForSelectedRow{
            existingGoal.thisGoal = self.goalsList[indexPath.row]
            //existingGoal.existingGoalCopy = goalsList[indexPath.row]
            existingGoal.isNewGoal = false
            existingGoal.deleteGoalDelegate? = self
            existingGoal.validGoalDelegate? = self
        }
    }
    
    //swipe to delete functionality
    func tableView(_ tableView: UITableView, editActionsForRowAt: IndexPath) -> [UITableViewRowAction]? {
        
            let showRemoveGoalSlideOption = UITableViewRowAction(style: .normal, title: "Delete") {
                action, index in
                let removedThisGoalWhenClicked = self.goalsList[index.row]
                //call are you sure window
                //self.GoalsAccess.deleteGoal(input: removedThisGoalWhenClicked)
                
                //self.removeThisGoalFromGoalsList( goalToRemove: removedThisGoalWhenClicked)
                self.deleteThisGoal( goalToDelete: removedThisGoalWhenClicked)
                self.update()
            }
            showRemoveGoalSlideOption.backgroundColor = UIColor.red
        return [showRemoveGoalSlideOption]
        
    }
    
    //checks if the input name is already used by another MyGoal in goalsList[]
    func isUniqueGoalName(inputNameString: String) -> Bool{
        
        var index = 0
        let limit = self.goalsList.count
        for index in 0..<limit {
            if inputNameString == self.goalsList[index].desciption {
                return false
            }
        }
        return true
    }
    
    func deleteThisGoal( goalToDelete: MyGoal) {
        //now pass to AccessService class to delete the coreDate NSObject for inputGoal
        print("!!!--- MADE IT TO GOALSVC deleteThisGoal func ---!!!")
        self.GoalsAccess.deleteGoal(input: goalToDelete)
    }
    
    func removeThisGoalFromGoalsList( goalToRemove: MyGoal) {
    
        var index = 0
        let limit = self.goalsList.count
        for index in 0..<limit {
            if goalToRemove.desciption == self.goalsList[index].desciption {
                print(">>>GOALSVC: removed \(goalToRemove.desciption) from goalsList\ngoalsList count before = \(goalsList.count)")
                self.goalsList.remove(at: index)
                print("goalsList count after = \(goalsList.count)")
            }
        }
        deleteThisGoal( goalToDelete: goalToRemove)
    }
    
}//end of class



































