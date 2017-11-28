//
//  Export.swift
//  BuildABudget
//
//  Created by chris on 11/26/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//

import Foundation
import UIKit

//Purpose of this class is to provide the methods for serializing the information stored in CoreDate into a csv file
//and exporting it via the user's prefered method to a destination airdrop device or email address.
class Export: ExportDelegate {
    
    //declare a static Export object so other classes can access this class easily
    static let transferAgent = Export()
    
    //declare class vars to allow access to DataModel classes easily
    let transactionAgent = MyTransaction()
    let goalsAgent = MyGoal()
    var tempPathToFile: URL? = nil
    
    
    //create a csv fileName -> filename format = BuildABudget-MM-DD-YYYY
    func newExportFileName() -> String {
        return "BuildABudget_" + MyDate.dateConverter.dateToDashedString(inputDate: Date()) + ".csv"
    }
    
    //Create and populate csv file with info from CoreDate
    func createExportFile() {
        
        print(">>>EXPORT: made it to createExportFile")
        //Create file name and a temp directory to store it in while we write to it
        let newFileName = newExportFileName()
        tempPathToFile = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(newFileName)
        
        //Grab all MyGoals, MyTransactions, and MyBudget data
        var allGoals:[MyGoal] = goalsAgent.getAllGoals()
        var allTransactions:[MyTransaction] = transactionAgent.getAllTransactions()
        let budgetName = "Budget_" + MyDate.dateConverter.dateToDashedString(inputDate: Date()) + " :"
        
        //Sort One-Time, reocurring expesenses, and reoccuring income MyTransaction objects into their own [myTransaction] for easiler writing
        var monthlyExpenses:[MyTransaction] = []
        var monthlyIncome:[MyTransaction] = []
        var oneTimeTransactions:[MyTransaction] = []
        
        var index = 0
        while (index < allTransactions.count) {
            let newItem = allTransactions[index]
            
            if newItem.isReoccuring == true {
                if newItem.isIncome == true {
                    monthlyIncome.append(newItem)
                } else {
                    monthlyExpenses.append(newItem)
                }
            }
            else {
                oneTimeTransactions.append(newItem)
            }
            
            index += 1
        }
        
        //create the initial csv file text line and the String var to store it all in -> this is only the budget name initially
        var fileText = "\(budgetName)\n"
        
        //append section heading Goals
        fileText.append("\nGoals:\n")
        
        //append all Goals
        var nextTextLine:String = "" //we will reuse this var throughout the creation of this csv file
        nextTextLine = "Desciption), Start Date,Target Date,Target Amount,Remaining Amount, Progress\n"
        fileText.append(nextTextLine)
        
        for item in allGoals {
            nextTextLine = "\(item.desciption),\(item.startDateToString()),\(item.tagetDateToString()),\(item.targetAmount),\(item.getRemainingAmount())\(item.getProgressString())\n"
            fileText.append(nextTextLine)
        }
        
        //append section heading Monthly Income
        fileText.append("\nMonthly Income Items:\n")
        nextTextLine = "Desciption, Start Date,Due Date,Total Due,Linked to Goal\n"
        fileText.append(nextTextLine)
        
        //append all monthly income items
        for item in monthlyIncome {
            nextTextLine = "\(item.desciption),\(item.initialInputDate),\(item.dueDate),\(item.totalDue),\(item.linkedToGoal)\n"
            fileText.append(nextTextLine)
        }
        
        //append section heading Monthly Expenses
        fileText.append("\nMonthly Expense Items:\n")
        nextTextLine = "Desciption, Start Date,Due Date,Total Due,Linked to Goal\n"
        fileText.append(nextTextLine)
        
        //append all monthly income items
        for item in monthlyExpenses {
            nextTextLine = "\(item.desciption),\(item.initialInputDate),\(item.dueDate),\(item.totalDue),\(item.linkedToGoal)\n"
            fileText.append(nextTextLine)
        }
        
        //append section heading One-Time Transactions
        fileText.append("\nOne-Time Transaction Items:\n")
        nextTextLine = "Desciption, Start Date,Due Date,Total Due,Linked to Goal\n"
        fileText.append(nextTextLine)
        
        //append all monthly income items
        for item in oneTimeTransactions {
            nextTextLine = "\(item.desciption),\(item.initialInputDate),\(item.datePaidOff),\(item.totalDue),\(item.linkedToGoal)\n"
            fileText.append(nextTextLine)
        }
        
        do {
            try fileText.write(to: tempPathToFile!, atomically: true, encoding: String.Encoding.utf8)
        } catch {
            print(">>>EXPORT: Failed to save csv file")
            print("\(error)")
        }
        //close the file and save it
        print(">>>EXPORT: finished createExportFile")
    }
    
    //protocol function
    func exportMyData( callingUIViewController: UIViewController) {
        //create the csv file
        print("MADE IT TO 128")
        createExportFile()
        
        //use input ViewController reference to launch the export GUI
        showExportOptions( callingUIViewController: callingUIViewController)
    }
    
    //choose method of export -> email or airDrop
    func showExportOptions( callingUIViewController: UIViewController) {
        
        guard let myPath = tempPathToFile else {
            print(">>>EXPORT: tempPathToFile == nil")
            return
        }
        
        print(">>>EXPORT: tempPathToFile !nil")
        let thisViewController = UIActivityViewController(activityItems: [myPath], applicationActivities: [])
        callingUIViewController.present(thisViewController, animated: true, completion: nil)
        
        /*
        thisViewController.excludedActivityTypes = [ UIActivityTypeAssignToContact,
                                                     UIActivityTypeSaveToCameraRoll,
                                                     UIActivityTypePostToFlickr,
                                                     UIActivityTypePostToVimeo,
                                                     UIActivityTypePostToTencentWeibo,
                                                     UIActivityTypePostToTwitter,
                                                     UIActivityTypePostToFacebook,
                                                     UIActivityTypeOpenInIBooks
        ]
 */
        
    }
    
    
    
    
    
}//end of class


