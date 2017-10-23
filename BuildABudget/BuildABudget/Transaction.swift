//
//  Transaction.swift
//  BuildABudget
//
//  Created by chris on 10/22/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
import Foundation

class Transaction {
    
    fileprivate var _id: String
    fileprivate var _description: String
    
    fileprivate var _initialInputDate: Date
    fileprivate var _dueDate: Date
    fileprivate var _datePaidOff: Date
    
    fileprivate var _balance: Double = 0.0
    fileprivate var _totalDue: Double = 0.0
    
    
    var id:String {
        get{ return _id}
        set(inputId){ _id = inputId}
    }
    
    var desciption:String {
        get{ return _description}
        set(inputDescription){ _description = inputDescription}
    }
    
    var initialInputDate:Date {
        get{ return _initialInputDate}
        set(inputInitialInputDate){ _initialInputDate = inputInitialInputDate}
    }
    
    var dueDate:Date {
        get{ return _dueDate}
        set(inputDueDate){ _dueDate = inputDueDate}
    }
    
    var datePaidOff:Date {
        get{ return _datePaidOff}
        set(inputDatePaidOff){ _datePaidOff = inputDatePaidOff}
    }
    
    var balance:Double {
        get{ return _balance}
        set(inputBalance){ _balance = inputBalance}
    }
    
    var totalDue:Double {
        get{ return _totalDue}
        set(inputTotalDue){ _totalDue = inputTotalDue}
    }
    
    
    init(description:String,
         dueDate:Date,
         datePaidOff:Date,
         balance:Double,
         totalDue:Double) {
        self._id = "\(description)-\(_initialInputDate)"
        self._description = description
        
        //let currentDateTime = Date()
        self._initialInputDate = Date()
        self._dueDate = dueDate
        self._datePaidOff = datePaidOff
        
        self._balance = balance
        self._totalDue = totalDue
    }
}
