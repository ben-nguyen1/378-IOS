//
//  MyGoal.swift
//  BuildABudget
//
//  Created by chris on 10/23/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
import Foundation

class MyGoal {
    
    //vars
    fileprivate var _description: String
    fileprivate var _startDate: Date
    fileprivate var _targetDate: Date
    fileprivate var _monthlyContribution: Double = 0.0 //monthyl expense that is setup by user and displayed on ChecklistViewController and BudgetViewController as expense
    fileprivate var _targetAmount: Double = 0.0 //running total of all transactions paid toward this goal
    
    //contributionList should only be accessed by the Checklist and Transactions class -> when those classes mark a transaction as paid that is linked to this specific goal then each instance of the transaction will be stored in the contribution list
    fileprivate var _contributionList: [MyTransaction] //list of all the transactions that that have gone toward paying for this goal
    
    
    //estimatedCompletionDate -> will be a calculation
    fileprivate var estimatedCompletionDate: Double = 0.0
    
    //amountRemaining -> a calculation
    fileprivate var amountRemaining: Double = 0.0
    
    //the percent of progress that this goal has based on the sum of all MyTransaction objects within the contributionList and the specified totalAmount
    fileprivate var progress:Float = 0.0
    
    //the sum of all MyTransaction object's totalDue amounts
    fileprivate var currentSavedAmount: Double = 0.0
    
    //instanciate a MyDate object to be used within this class
    let goalsDate = MyDate.dateConverter
    
    let goalsAccess = AccessService.access
    
    
    //getters/setters
    var desciption:String {
        get{ return _description}
        set(inputDescription){ _description = inputDescription}
    }
    
    var startDate:Date {
        get{ return _startDate}
        set(inputDate){ _startDate = startDate}
    }
    
    var targetDate:Date {
        get{ return _targetDate}
        set(inputDate){ _targetDate = targetDate}
    }
    
    var monthlyContribution:Double {
        get{ return _monthlyContribution}
        set(inputAmount){ _monthlyContribution = monthlyContribution}
    }
    
    var targetAmount:Double {
        get{ return _targetAmount}
        set(inputAmount){ _targetAmount = targetAmount}
    }
    
    //contributionList methods
    var allContributions: [MyTransaction]{
        get{ return _contributionList}
        set(inputContributions){ _contributionList = inputContributions }
    }
    
    //return the targetDate as a string
    func tagetDateToString() -> String{
        return goalsDate.shortDateToString(inputDate: _targetDate)
    }
    
    //return the startDate as a string
    func startDateToString() -> String{
        return goalsDate.shortDateToString(inputDate: _startDate)
    }
    
    func getProgress() -> Float{
        return Float(currentSavedAmount/targetAmount)
    }
    
    
    
    
    //STILL NEED TO COMPLETE
    //func for calculating the estimated completion date
    func getEstimatedCompletionDate(inputStartDate: Date, inputTargetAmount: Double, inputContributionAmount: Double) -> Double {
        // got nothing yet...come back later
        
        //targetAmount / contributionAmount (per month) = numberOfWeeks
        let originalNumberOfWeeks:Int = Int(round(inputTargetAmount/inputContributionAmount))
        //Date calculation -> (StartDate + numberOfWeeks
        
        
        
        return 0.0//temp value
    }
    
    //loop through all MyTransaction objects in contributionList and adds up the totalDue amounts.
    func getCurrentSavedAmount( inputContributionList: [MyTransaction]) -> Double {
        var total = 0.0
        for index in inputContributionList {
            total += total + index.totalDue
        }
        return total
    }
    
    func getRemainingAmount( inputTargetAmount: Double, inputCurrentSavedAmount: Double) -> Double {
        return inputTargetAmount - inputCurrentSavedAmount
    }
    
    func calculateProgress(inputTargetAmount: Double, inputCurrentSavedAmount: Double) -> Double{
        return inputCurrentSavedAmount / inputTargetAmount
    }
    
    func saveMyGoal(inputGoal: MyGoal){
        goalsAccess.saveGoal(input: inputGoal)
    }
    
    func deleteMyGoal(inputGoal: MyGoal){
        goalsAccess.deleteGoal(input: inputGoal)
    }
    
    
    class func create ( iDescription:String,
                        iStartDate:Date,
                        iTargetDate:Date,
                        iMonthlyContribution:Double,
                        iTargetAmount:Double,
                        iContributionList: [MyTransaction] ) -> MyGoal {
     
        return MyGoal ( description: iDescription,
                        startDate: iStartDate,
                        targetDate: iTargetDate,
                        monthlyContribution: iMonthlyContribution,
                        targetAmount: iTargetAmount,
                        contributionList: iContributionList)
    }
    
    
    //initializers
    init(description:String,
         startDate:Date,
         targetDate:Date,
         monthlyContribution:Double,
         targetAmount:Double,
         contributionList: [MyTransaction]) {
        
        self._description = description
        self._startDate = startDate
        self._targetDate = targetDate
        self._monthlyContribution = monthlyContribution
        self._targetAmount = targetAmount
        self._contributionList = []
    }
    
    init(){
        self._description = "error"
        self._startDate = goalsDate.setToYesterday(today: Date())
        self._targetDate = goalsDate.setToYesterday(today: Date())
        self._monthlyContribution = -1.0
        self._targetAmount = -1.0
        self._contributionList = []
    }
    
}















