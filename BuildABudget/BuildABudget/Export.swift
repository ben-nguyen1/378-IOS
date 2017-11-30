//  Export.swift
//  BuildABudget
//
//  Created by chris on 11/26/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//

import MessageUI
import UIKit

//, MFMailComposeViewControllerDelegate

//Purpose of this class is to provide the methods for serializing the information stored in CoreDate into a csv file
//and exporting it via the user's prefered method to a destination airdrop device or email address.
class Export: ExportDelegate {
    
    //var description: String
    //var callingViewController: UIViewController?
    
    //declare a static Export object so other classes can access this class easily
    static let transferAgent = Export()
    
    //declare class vars to allow access to DataModel classes easily
    let transactionAgent = MyTransaction()
    let goalsAgent = MyGoal()
    
    //setup file manager stuff
    var documentDirURL: URL? = nil
    var fileNameURL: URL? = nil
    var fileName = ""
    var fileCounter = 0
    
    
    //create a csv fileName -> filename format = BuildABudget-MM-DD-YYYY
    func newExportFileName() -> String {
        return "BuildABudget_" + MyDate.dateConverter.dateToDashedString(inputDate: Date())
    }
    
    //Generate string with csv formatting from CoreData
    func createExportFileText() -> String{
        
        print(">>>EXPORT: generating text for csv file")
        
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
        
        return fileText
    }
    
    func createNewFile( inputDataString: String, inputVC: UIViewController) {
        
        //update DOcumentDirURL, newFilePathURL, fileName
        documentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        fileName = newExportFileName()
        fileNameURL = documentDirURL?.appendingPathComponent(fileName).appendingPathExtension("csv")
        
        
        showExportOptions( callingUIViewController: inputVC)
        //fileNameURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(newFileName)
        
        do {
            try inputDataString.write(to: fileNameURL!, atomically: true, encoding: String.Encoding.utf8)
            print(">>>EXPORT: Succssfully wrote \(fileName) to: \(fileNameURL)")
        } catch let error as NSError{
            print(">>>EXPORT: Failed to write \(fileName) due to: " + error.localizedDescription)
        }
        //close the file and save it
        print(">>>EXPORT: finished createExportFile")
        
    }
    
    
    //protocol function
    func exportMyData( callingUIViewController: UIViewController) {
        //create the csv file
        print(">>>EXPORT: starting the export process")
        let data = createExportFileText()
        createNewFile( inputDataString: data, inputVC: callingUIViewController)
        print(">>>EXPORT: finished writing csv file to local dir -> check files app")
    }
    
    //choose method of export -> email or airDrop
    func showExportOptions( callingUIViewController: UIViewController) {
        
        guard let myPath = fileNameURL else {
            print(">>>EXPORT: tempPathToFile == nil")
            return
        }
        
        print(">>>EXPORT: tempPathToFile !nil")
        let exportAppChoiceViewController = UIActivityViewController(activityItems: [myPath], applicationActivities: [])
        exportAppChoiceViewController.excludedActivityTypes = [ UIActivityType.assignToContact,
                                                     UIActivityType.saveToCameraRoll,
                                                     UIActivityType.postToFlickr,
                                                     UIActivityType.postToVimeo,
                                                     UIActivityType.postToTencentWeibo,
                                                     UIActivityType.postToTwitter,
                                                     UIActivityType.postToFacebook,
                                                     UIActivityType.openInIBooks ]
        
        exportAppChoiceViewController.completionWithItemsHandler = { activity, success, items, error in
            if !success{
                print("cancelled")
                return
            }
            
            if activity == UIActivityType.mail {
                self.configureMailController(thisViewController: exportAppChoiceViewController)
                print(">>>EXPORT: starting new email -> prefilling fields: TO, SUBJECT, BODY")
            }
            
            if activity == UIActivityType.mail {
                print("mail")
            }
            
        }
        //callingUIViewController.present(exportAppChoiceViewController, animated: true, completion: nil)
        
        callingUIViewController.present(exportAppChoiceViewController, animated: true, completion: nil)

        
        
        
        
        
        
        
        
    }
    
    //Email specific functions:
    func configureMailController(thisViewController: UIViewController) -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = thisViewController as? MFMailComposeViewControllerDelegate
        
        //set up values for email fields
        let toEmailField = UserDefaults.standard.object(forKey: "userName") as! String
        let subjectEmailField = "BuildABudget export"
        let messageEmailBody = "See attached BuildABudget csv file."
        
        mailComposerVC.setToRecipients([toEmailField])
        mailComposerVC.setSubject( subjectEmailField )
        mailComposerVC.setMessageBody( messageEmailBody, isHTML: false)
        
        return mailComposerVC
    }
    
    /*
    func showMailError( thisViewController: UIViewController) {
        let sendMailErrorAlert = UIAlertController(title: "Could not send email", message: "Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: .default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
 */
    
    //Default initializer
    //init() { }
    
    
}//end of class


