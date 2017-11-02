//
//  Transaction.swift
//  BuildABudget
//
//  Created by chris on 10/22/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
import Foundation

class MyTransaction {
    
    fileprivate var _description: String
    fileprivate var _initialInputDate: Date
    fileprivate var _dueDate: Date
    fileprivate var _datePaidOff: Date
    fileprivate var _totalDue: Double = 0.0
    fileprivate var _isReoccuring: Bool
    fileprivate var _isIncome: Bool
    
    var date = MyDate() //instance of MyDate class to get access to its methods
    
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
    
    var totalDue:Double {
        get{ return _totalDue}
        set(inputTotalDue){ _totalDue = inputTotalDue}
    }
    
    var isReoccuring:Bool {
        get{ return _isReoccuring}
        set(inputIsReoccuring){ _isReoccuring = inputIsReoccuring}
    }
    
    var isIncome:Bool {
        get{ return _isIncome}
        set(inputIsIncome){ _isIncome = inputIsIncome}
    }
    
    //functions below
    func isPastDue() -> Bool {
        
        if _datePaidOff > _initialInputDate{
            return true
        } else{
            return false
        }
        
    }

    //creates a new MyTransaction Object
    class func create(iDes:String,
                iIniDate:Date,
                iDueDate:Date,
                iDatePaidOff:Date,
                iTotalDue:Double,
                iIsReoccuring:Bool,
                iIsIncome:Bool) -> MyTransaction{
        
        return MyTransaction(description: iDes,
                             initialInputDate:  iIniDate,
                             dueDate:           iDueDate,
                             datePaidOff:       iDatePaidOff,
                             totalDue:          iTotalDue,
                             isReoccuring:      iIsReoccuring,
                             isIncome:          iIsIncome)
    }
    
    //for when this transaction is returned from CoreData
    init(description:       String,
         initialInputDate:  Date,
         dueDate:           Date,
         datePaidOff:       Date,
         totalDue:          Double,
         isReoccuring:      Bool,
         isIncome:          Bool) {
        
        self._description = description
        self._initialInputDate = initialInputDate
        self._dueDate = dueDate
        self._datePaidOff = datePaidOff
        self._totalDue = totalDue
        self._isReoccuring = isReoccuring
        self._isIncome = isIncome
    }
    
    //for brand new transactions
    init(description:       String,
         dueDate:           Date,
         totalDue:          Double,
         isReoccuring:      Bool,
         isIncome:          Bool) {
        
        self._description = description
        self._initialInputDate = Date()
        self._dueDate = dueDate
        self._datePaidOff = date.setToYesterday( today: Date() )//setting this Date to yesterday's date indicates that the bill has not been paid off.
        self._totalDue = totalDue
        self._isReoccuring = isReoccuring
        self._isIncome = isIncome
    }
    
    //incase the access object hits and error and needs to return something so the app does not crash
    init(){
        self._description = "error"
        self._initialInputDate = Date()
        self._dueDate = Date()
        self._datePaidOff = Date()
        self._totalDue = 0.0
        self._isReoccuring = false
        self._isIncome = false
    }
 
}








