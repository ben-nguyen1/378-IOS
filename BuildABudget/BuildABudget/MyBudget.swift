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
    
    
    
    
    //initializers
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
    
    
    init(){
        self._description = "error"
        self._startDate = Date()
        self._endDate = Date()
        self._expenseSources = []
        self._incomeSources = []
    }
    
}
















