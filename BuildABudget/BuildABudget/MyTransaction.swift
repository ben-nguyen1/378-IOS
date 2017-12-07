//
//  Transaction.swift
//  BuildABudget
//
//  Created by chris on 10/22/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
import Foundation
import UIKit
import EventKit

class MyTransaction {
    
    fileprivate var _linkedToGoal: String
    fileprivate var _description: String
    fileprivate var _initialInputDate: Date
    fileprivate var _dueDate: Date
    fileprivate var _datePaidOff: Date
    fileprivate var _totalDue: Double = 0.0
    fileprivate var _isReoccuring: Bool
    fileprivate var _isIncome: Bool
    fileprivate var _reminderID: String
    
    let date = MyDate() //instance of MyDate class to get access to its methods
    let transactionAccess = AccessService.access //allows MyTransaction class to access the MyTransactions in CoreData
    let reminderAccess = Reminders.agent
    static let agent = MyTransaction()
    
    var reminderID:String {
        get{ return _reminderID}
        set(inputGoalName){ _reminderID = reminderID}
    }
    
    var linkedToGoal:String {
        get{ return _linkedToGoal}
        set(inputGoalName){ _linkedToGoal = inputGoalName}
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
    
    //Returns a list of all MyTransactions objects in CoreDate
    func getAllTransactions() -> [MyTransaction]{
        
        var allTransactions: [MyTransaction] = []
        transactionAccess.retreiveAllTransactions()
        
        var i = 0
        while (i < transactionAccess.totalTransactions()) {
            let newItem = transactionAccess.getTransaction(index: i)
            allTransactions.append(newItem)
            i += 1
        }
        return allTransactions
    }
    
    //Returns a list of all Reoccuring MyTransactions objects in CoreDate that are not linked to a Goal that is paid off
    func getAllReoccuringTransactions() -> [MyTransaction]{
        var allTransactions: [MyTransaction] = []
        transactionAccess.retreiveAllTransactions()
        
        var i = 0
        while (i < transactionAccess.totalTransactions()) {
            let newItem = transactionAccess.getTransaction(index: i)
            var checkGoal = MyGoal.init()
            checkGoal = checkGoal.findMyGoalByName(inputName: newItem.linkedToGoal)
            if newItem.isReoccuring && checkGoal.getRemainingAmount() > 0 {
                allTransactions.append(newItem)
            }
            i += 1
        }
        return allTransactions
    }
    
    //Returns a list of all NON-Reoccuring MyTransactions objects in CoreDate
    func getAllNonReoccuringTransactions() -> [MyTransaction]{
        var allTransactions: [MyTransaction] = []
        transactionAccess.retreiveAllTransactions()
        
        var i = 0
        while (i < transactionAccess.totalTransactions()) {
            let newItem = transactionAccess.getTransaction(index: i)
            if !newItem.isReoccuring {
                allTransactions.append(newItem)
            }
            i += 1
        }
        return allTransactions
    }
    
    //create a copy of MyTransaction
    func copy( originalTransaction: MyTransaction) -> MyTransaction{
        return  MyTransaction.init(description: originalTransaction.desciption,
                                  initialInputDate: originalTransaction.initialInputDate,
                                  dueDate: originalTransaction.dueDate,
                                  datePaidOff: originalTransaction.datePaidOff,
                                  totalDue: originalTransaction.totalDue,
                                  isReoccuring: false, //this was changed from the original since we only want to have non-reoccuring copies of the reoccurin MyTransactions showing in this screen -> so that deleting the object on this screen will not cause the original on the BudgetViewController to also be deleted.
                                  isIncome: originalTransaction.isIncome,
                                  isLinkedToGoal: originalTransaction.linkedToGoal,
                                  reminderID: "")//we do not want to create a reminder ID since single transactions will not be tracked on the calendar
    }
    
    //finds if this transaction is unique based on the inputTransaction description and the LinkedToGoal property
    func findMyTransactionLinkedToMyGoal( inputDescription: String ) -> MyTransaction{
        
        let list = getAllTransactions()
        for item in list {
            if item.desciption == inputDescription && item.linkedToGoal == inputDescription {
                return item
            }
        }
        
        //We only get here if we did not find anything
        print(">>>MYTRANSACTION: ERROR -> could not find the linked MyTransaction for goal")
        return MyTransaction.init() //the description property of thie MyTransaction is set to "error" which is what we will check in the calling function
    }

    //checks if the remainning amount of a MyGoal linked MyTransaction is less than the monthlyContribution amount -> returns the lowest value
    func adjustExpenseAmountString( inputTransaction: MyTransaction) -> String {
        
        var adjustAmount = inputTransaction.totalDue
        var linkedMyGoal = MyGoal() //dummy value
        linkedMyGoal = linkedMyGoal.findMyGoalByName(inputName: inputTransaction.linkedToGoal)
        if (inputTransaction.totalDue > linkedMyGoal.getRemainingAmount()) && linkedMyGoal.desciption != "error" {
            adjustAmount = linkedMyGoal.getRemainingAmount()
        }
        let stringAmount = String( adjustAmount )
        return stringAmount
    }
    
    func adjustExpenseAmountDouble( inputTransaction: MyTransaction) -> Double {
        
        var adjustAmount = inputTransaction.totalDue
        var linkedMyGoal = MyGoal() //dummy value
        linkedMyGoal = linkedMyGoal.findMyGoalByName(inputName: inputTransaction.linkedToGoal)
        if (inputTransaction.totalDue > linkedMyGoal.getRemainingAmount()) && linkedMyGoal.desciption != "error" {
            adjustAmount = linkedMyGoal.getRemainingAmount()
        }
        print("TEST: adjustAmount = \(adjustAmount)")
        return adjustAmount
    }
    
    func setCalReminder( callingVC: UIViewController, inputTransaction: MyTransaction) {
        reminderAccess.createCalendarEvent(callingUIViewController: callingVC, inputTransaction: inputTransaction )
    }
    
    func removeOldCalReminder(callingVC: UIViewController, inputTransaction: MyTransaction) {
        reminderAccess.deleteCalendarEvent(callingUIViewController: callingVC, callingReoccuringTransaction: inputTransaction)
    }
    
    func linkedTransactionHasAmountGreaterThanZero( inputTransaction: MyTransaction) -> Bool {
        var linkedMyGoal = MyGoal() //dummy value
        linkedMyGoal = linkedMyGoal.findMyGoalByName(inputName: inputTransaction.linkedToGoal)
        if linkedMyGoal.getRemainingAmount() == 0.0 && linkedMyGoal.desciption != "error" {
            return false //indicates that this MyTransaction should not be listed since it has a value of 0 -> this means we have already paid off the goal but the user has not deleted the completed Goal
        }
        return true
        
    }
    
    //func hasReoccurringExpenseBeenPaid
    
    //creates a new MyTransaction Object for any calling Class
    class func create(iDes:             String,
                      iIniDate:         Date,
                      iDueDate:         Date,
                      iDatePaidOff:     Date,
                      iTotalDue:        Double,
                      iIsReoccuring:    Bool,
                      iIsIncome:        Bool,
                      iLinkedToGoal:    String,
                      iReminderID:      String, //unless a calendarEventIdentifier string is already known this should be set to "" when called
                      createNewReminder:Bool, //if iReminderID is set to anything but "" this should be set to false
                      callingVC:        UIViewController ) -> MyTransaction{
        
        //create the new MyTransaction
        let newTransaction = MyTransaction(description:       iDes,
                                           initialInputDate:  iIniDate,
                                           dueDate:           iDueDate,
                                           datePaidOff:       iDatePaidOff,
                                           totalDue:          iTotalDue,
                                           isReoccuring:      iIsReoccuring,
                                           isIncome:          iIsIncome,
                                           isLinkedToGoal:    iLinkedToGoal,
                                           reminderID:        iReminderID )
        
        //delete the old calendar event and then create a new calendar event
        if createNewReminder == true {
            
            //if there is an existing MyTransaction object that is linked to this MyGoal already -> delete it
            if iLinkedToGoal != "" {
                let transactionToDelete = newTransaction.findMyTransactionLinkedToMyGoal( inputDescription: iLinkedToGoal)
                transactionToDelete.removeOldCalReminder( callingVC: callingVC, inputTransaction: transactionToDelete)
            }
            newTransaction.setCalReminder( callingVC: callingVC, inputTransaction: newTransaction)
        }
        
        return newTransaction
    }
    
    class func createMonthlyGoalContribution(iDes:          String,
                                             iIniDate:      Date,
                                             iDueDate:      Date,
                                             iDatePaidOff:  Date,
                                             iTotalDue:     Double,
                                             iIsReoccuring: Bool,
                                             iIsIncome:     Bool,
                                             iLinkedToGoal: String,
                                             iReminderID:   String) -> MyTransaction{
        
        return MyTransaction(description:       iDes,
                             initialInputDate:  iIniDate,
                             dueDate:           iDueDate,
                             datePaidOff:       iDatePaidOff,
                             totalDue:          iTotalDue,
                             isReoccuring:      iIsReoccuring,
                             isIncome:          iIsIncome,
                             isLinkedToGoal:    iLinkedToGoal,
                             reminderID:        iReminderID)
    }
    
    
    //called only by the MyTransaction class func create or for when this transaction is returned from AccessService -> do not use for any other Class because this will not create a Calendar reminder -> use func create when calling from any other Class but AccessService
    init(description:       String,
         initialInputDate:  Date,
         dueDate:           Date,
         datePaidOff:       Date,
         totalDue:          Double,
         isReoccuring:      Bool,
         isIncome:          Bool,
         isLinkedToGoal:    String,
         reminderID:        String ) {
        
        self._description = description
        self._initialInputDate = initialInputDate
        self._dueDate = dueDate
        self._datePaidOff = datePaidOff
        self._totalDue = totalDue
        self._isReoccuring = isReoccuring
        self._isIncome = isIncome
        self._linkedToGoal = isLinkedToGoal
        self._reminderID = reminderID
    }
    
    //USE this initializer to return errors (and keep the code from crashing) or as a dummy object -> if you need to create a new object call func create
    init(){
        self._description = "error" //note many functions in ViewController classes check if this attribute is set to "error" to detect if a function has returned a dummy object because an error occured
        self._initialInputDate = Date()
        self._dueDate = Date()
        self._datePaidOff = Date()
        self._totalDue = 0.0
        self._isReoccuring = false
        self._isIncome = false
        self._linkedToGoal = ""
        self._reminderID = ""
    }
}








