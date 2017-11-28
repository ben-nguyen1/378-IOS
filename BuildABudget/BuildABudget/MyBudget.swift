//
//  MyBudget.swift
//  BuildABudget
//
//  Created by chris on 10/23/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
//
//  MyGoal.swift
//  BuildABudget
//
//  Created by chris on 10/23/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
import Foundation

class MyBudget {
    
    //vars
    fileprivate var _description: String
    
    fileprivate var _startDate: Date
    fileprivate var _endDate: Date//may need to be revised to match to end of month instead of keeping as a static date
    
    fileprivate var _expenseSources: [MyTransaction] //list all monthly bills
    fileprivate var _incomeSources: [MyTransaction] //list all income streams

    //getters/setters
    var desciption:String {
        get{ return _description}
        set(inputDescription){ _description = inputDescription}
    }
    
    var startDate:Date {
        get{ return _startDate}
        set(inputDate){ _startDate = startDate}
    }
    
    var endDate:Date {
        get{ return _endDate}
        set(inputDate){ _endDate = endDate}
    }
    
    var allExpenses: [MyTransaction]{
        get{ return _expenseSources}
        set(inputExpense){ _expenseSources = inputExpense }
    }
    
    var allIncome: [MyTransaction]{
        get{ return _incomeSources}
        set(inputIncome){ _incomeSources = inputIncome }
    }
    
    func exportBudget() {
        //The Budget that will be exported will be the up-to-date current budget that is seen by the user in the BudgetViewController

        //NOTE: we are not allowing the user to setup multiple budgets since this is meant to serve a personal budget -> when
        //      the user changes their personal budget they will not have to save or sort through multiple budgets to display
        //      the budget they currently want because only one budget is allowed.
        
        //Step 1: gather all data points
        let budgetDescription = "Budget_" + MyDate.dateConverter.dateToDashedString(inputDate: Date())
        var currentBudgetAccess = BudgetViewController.bc
        //let budgetExpenseList = currentBudgetAccess.
        
    }
    
    //initializers
    //only for when the access object successfully returns a MyBudget object
    init(description:String,
         startDate:Date,
         endDate:Date,
         expenseSources:[MyTransaction],
         incomeSources:[MyTransaction]
        ) {
        
        self._description = description
        self._startDate = startDate
        self._endDate = endDate
        self._expenseSources = expenseSources
        self._incomeSources = incomeSources
    }
    //only for when a brand new MyBudget object is created
    init(description:String,
         startDate:Date,
         endDate:Date
         ) {
        
        self._description = description
        self._startDate = startDate
        self._endDate = endDate
        self._expenseSources = []
        self._incomeSources = []
    }
    
    //when the access object has to return an error
    init(){
        self._description = "error"
        self._startDate = Date()
        self._endDate = Date()
        self._expenseSources = []
        self._incomeSources = []
    }
}
















