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
    fileprivate var _endDate: Date
    
    fileprivate var _monthlyContribution: Double = 0.0 //monthyl expense that is setup by user and displayed on ChecklistViewController and BudgetViewController as expense
    fileprivate var _totalContribution: Double = 0.0 //running total of all transactions paid toward this goal
    
    fileprivate var _contributionList: [MyTransaction] //list of all the transactions that that have gone toward paying for this goal
    
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
    
    var monthlyContribution:Double {
        get{ return _monthlyContribution}
        set(inputAmount){ _monthlyContribution = monthlyContribution}
    }
    
    var totalContribution:Double {
        get{ return _totalContribution}
        set(inputAmount){ _totalContribution = totalContribution}
    }
    
    //contributionList methods
    var allContributions: [MyTransaction]{
        get{ return _contributionList}
        set(inputContributions){ _contributionList = inputContributions }
    }
    
    //initializers
    init(description:String,
         startDate:Date,
         endDate:Date,
         monthlyContribution:Double,
         totalContribution:Double,
         contributionList: [MyTransaction]) {
        
        self._description = description
        self._startDate = startDate
        self._endDate = endDate
        self._monthlyContribution = monthlyContribution
        self._totalContribution = totalContribution
        self._contributionList = []
    }
    
    init(){
        self._description = "error"
        self._startDate = Date()
        self._endDate = Date()
        self._monthlyContribution = 0.0
        self._totalContribution = 0.0
        self._contributionList = []
    }
    
}















