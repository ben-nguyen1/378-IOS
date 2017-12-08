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
    fileprivate var _contributionList: Double
    
    //estimatedCompletionDate -> will be a calculation
    fileprivate var estimatedCompletionDate: Date? = nil
    
    //amountRemaining -> a calculation
    fileprivate var amountRemaining: Double = 0.0
    
    //the percent of progress that this goal has based on the sum of all MyTransaction objects within the contributionList and the specified totalAmount
    fileprivate var progress:Double = 0.0
    
    //the sum of all MyTransaction object's totalDue amounts
    fileprivate var currentSavedAmount: Double = 0.0
    
    //instanciate a MyDate object to be used within this class
    let goalsDate = MyDate.dateConverter
    let goalsAccess = AccessService.access
    let goalsReminder = Reminders.agent
    
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
    
    //Returns a list of all MyGoals objects in CoreDate
    func getAllGoals() -> [MyGoal]{
        
        var allGoals: [MyGoal] = []
        goalsAccess.retreiveAllGoals()
        
        var i = 0
        while (i < goalsAccess.totalGoals()) {
            let newItem = goalsAccess.getGoal(index: i)
            allGoals.append(newItem)
            i += 1
        }
        return allGoals
    }
    
    //contributionList methods
    var allContributions: Double{
        get{ return _contributionList}
        set(inputContributions){ _contributionList = inputContributions }
    }
    
    //ToString FUNCTIONS
    //return the targetDate as a string
    func tagetDateToString() -> String{
        return goalsDate.dateToString(inputDate: _targetDate)
    }
    
    //return the startDate as a string
    func startDateToString() -> String{
        return goalsDate.shortDateToString(inputDate: _startDate)
    }
    
    //return the monthly contribution as a String
    func monthlyContributionToString() -> String{
        return String(monthlyContribution)
    }
    
    func targetAmountToString() -> String {
        return String(targetAmount)
    }
    
    func setEqualToGoal( oldGoal: MyGoal) -> MyGoal {
        
        return MyGoal.create(iContributionList: oldGoal.allContributions,
                             iDescription: oldGoal.desciption,
                             iMonthlyContribution: oldGoal.monthlyContribution,
                             iStartDate: oldGoal.startDate,
                             iTargetDate: oldGoal.targetDate,
                             iTargetAmount: oldGoal.targetAmount)
        
    }
    
    //func for calculating the estimated completion date
    func getEstimatedCompletionDate() -> Date {
        
        let numDaysSinceStartOfGoal = goalsDate.dateDifferenceInDays(inputStartDate: self.startDate, inputEndDate: self.targetDate)
        var moneyRatio = 0.0
        if self.getCurrentSavedAmount() == 0.0 {
            moneyRatio = 1.0
        }
        else {
            moneyRatio = self.getRemainingAmount() / self.getCurrentSavedAmount()
        }
        let estimatedDaysLeftDouble = (moneyRatio * Double(numDaysSinceStartOfGoal) ).rounded(.up)
        let estimatedDaysLeftInt = Int(exactly: estimatedDaysLeftDouble)
        return goalsDate.getDateXNumDaysFromNow(inputStartDate: Date(), inputXNumDays: estimatedDaysLeftInt!)
     }
    
    //loop through all MyTransaction objects in contributionList and adds up the totalDue amounts.
    func getCurrentSavedAmount() -> Double {
        return _contributionList
    }
    
    func getRemainingAmount() -> Double {
        print("Goal name = \(self.targetAmount) - \(self._contributionList)")
        var subTotal =  self.targetAmount - self._contributionList
        if subTotal < 0 {
            subTotal = 0
        }
        return subTotal
    }
    
    func getProgressString() -> String{
        let tempDouble:Double =  (self.getCurrentSavedAmount() / self.targetAmount) * 100
        return String(format: "%.2F", tempDouble )
    }
    
    func getProgress() -> Float{
        return Float(self.getCurrentSavedAmount() / self.targetAmount) * 100
    }
    
    func saveMyGoal(inputGoal: MyGoal){
        goalsAccess.saveGoal(input: inputGoal)
    }
    
    func deleteMyGoal(inputGoal: MyGoal){
        goalsAccess.deleteGoal(input: inputGoal)
    }
    
    
    class func create ( iContributionList:      Double,
                        iDescription:           String,
                        iMonthlyContribution:   Double,
                        iStartDate:             Date,
                        iTargetDate:            Date,
                        iTargetAmount:          Double ) -> MyGoal {
     
        return MyGoal ( contributionList:       iContributionList,
                        description:            iDescription,
                        monthlyContribution:    iMonthlyContribution,
                        startDate:              iStartDate,
                        targetDate:             iTargetDate,
                        targetAmount:           iTargetAmount )
    }
    
    func findMyGoalByName( inputName: String) -> MyGoal {
        
        let list = getAllGoals()
        for item in list {
            if item.desciption == inputName{
                return item
            }
        }
        return MyGoal() //this has a description of "error" which indicates that we have not found the MyGoal object we searched for
    }
    
    //initializers
    init( contributionList:     Double,
          description:          String,
          monthlyContribution:  Double,
          startDate:            Date,
          targetDate:           Date,
          targetAmount:         Double ) {
        
        self._description         = description
        self._startDate           = startDate
        self._targetDate          = targetDate
        self._monthlyContribution = monthlyContribution
        self._targetAmount        = targetAmount
        self._contributionList    = contributionList
    }
    
    init(){
        self._description         = "error"
        self._startDate           = goalsDate.setToYesterday(today: Date())
        self._targetDate          = goalsDate.setToYesterday(today: Date())
        self._monthlyContribution = -1.0
        self._targetAmount        = -1.0
        self._contributionList    = 0.0
    }
}















