//
//  Reminders.swift
//  BuildABudget
//
//  Created by chris on 11/28/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//
import Foundation
import UIKit
import EventKit

//this calls provides the methods for all calendar events
class Reminders {
    
    static let agent = Reminders()
    let eventStore = EKEventStore()
    var calendarIdKey:String = ""
    var calendarTitle = "BuildABudget"
    static let cal = Reminders()
    let thisDate = MyDate.dateConverter
    
    //============================================================================================

    func getCalendar() -> EKCalendar {
        return eventStore.calendar(withIdentifier: Account.calId())!
    }
    
    //check if authorized to access calendar
    func checkAuthorization( callingUIViewController: UIViewController ) -> Bool{
        
        let status = EKEventStore.authorizationStatus(for: .event)
        var storedCalendar:EKCalendar? = nil
        if UserDefaults.standard.object(forKey: "calID") != nil {
            storedCalendar = eventStore.calendar(withIdentifier: Account.calId())
        }
        
        switch (status) {
        case .notDetermined: //for when we have never asked the user
            print(">>>REMINDERS: NOT DETERMINED -> jumping to needPermission func")
            initialAskForCalendarPermissions(callingUIViewController: callingUIViewController)
        case .authorized: //check that the calendar still exists
            if storedCalendar ==  nil {
                print(">>>REMINDERS: storedCalendar is nil -> creating new BuildABUdget calendar")
                createCalendar( callingUIViewController: callingUIViewController )
                return true
            }
            else if (storedCalendar !=  nil && storedCalendar?.title ==  calendarTitle){
                print(">>>REMINDERS: Authorized to make changes")
                return true
            }
            else if (storedCalendar !=  nil && storedCalendar?.title !=  calendarTitle){
                print(">>>REMINDERS: Calendar has wrong title -> need to correct this")
                return false
            }
            else {
                print(">>>REMINDERS: Authorized to make changes")
                return false
            }
        case .restricted, .denied:
            // Help the user give us permission to access the calendar.
            subsequentAskForCalendarPermissions( inputUIViewController: callingUIViewController )
            return false
        }
        
        print(">>>REMINDER: MADE TO END OF checkAuthorization")
        return false
    }
    
    //the first time we ask a user for permissions -> iOS remembers the choice thereafter
    func initialAskForCalendarPermissions( callingUIViewController: UIViewController ) {
        // Display an alert controller, telling the user what we need.
        DispatchQueue.main.async(execute: {
            
            self.eventStore.requestAccess(to: EKEntityType.event, completion: {
                (accessGranted: Bool, error: Error?) in
                
                if accessGranted == true {
                    DispatchQueue.main.async(execute: {
                        print("Permission granted by user")
                        self.createCalendar( callingUIViewController: callingUIViewController )
                    })
                } else {
                    DispatchQueue.main.async(execute: {
                        print("Permission still denyed by user")
                    })
                }
            })
        })
    }
    
    //takes user to settings menu and shows them which option to turn on
    func subsequentAskForCalendarPermissions( inputUIViewController: UIViewController){
        let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
        UIApplication.shared.open(openSettingsUrl!, options: [:], completionHandler: nil)
        let status = EKEventStore.authorizationStatus(for: .event)
        if status == .authorized {
            createCalendar( callingUIViewController: inputUIViewController )
        }
    }
    
    //============================================================================================

    //create a new calendar
    func createCalendar( callingUIViewController: UIViewController ) {
        
        // Use Event Store to create a new calendar instance.
        // Configure its title.
        let newCalendar = EKCalendar(for: .event, eventStore: eventStore)
        newCalendar.title = calendarTitle
        self.calendarIdKey = newCalendar.calendarIdentifier
            
        //set the newly created calendar as the UserDefaults Calendar
        print("!----- self.calendarIdKey = \(self.calendarIdKey) ----> newCalendar.calendarIdentifier = \(newCalendar.calendarIdentifier)")
        Account.setCalId( self.calendarIdKey )
        
        // Access list of available sources from the Event Store.
        // A source represents an account that a calendar belongs to.
        let sourcesInEventStore = eventStore.sources
        
        // Filter the available sources and select the "Local" source to assign to the new calendar's source property.
        // If none found, select the "calDAV" source.
        var filteredCalendarList = sourcesInEventStore.filter{
            (source: EKSource) -> Bool in
            source.sourceType == .local
        }
        
        if filteredCalendarList.first == nil {
            print(">>>REMINDER: fileredCalendarList.first == nil !!")
            filteredCalendarList = sourcesInEventStore.filter{
                (source: EKSource) -> Bool in
                source.sourceType == .calDAV
            }
        }
        newCalendar.source = filteredCalendarList.first!
        
        // Save the calendar using the Event Store instance
        do {
            try eventStore.saveCalendar(newCalendar, commit: true)
            
            // Store the calendar id locally. To allow us to get this calendar later.
            UserDefaults.standard.set(newCalendar.calendarIdentifier, forKey: calendarIdKey)
            UserDefaults.standard.synchronize()
            
            let alert = UIAlertController(title: "New BuildABudget Calendar", message: "Calendar was saved", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            callingUIViewController.present(alert, animated: true, completion: nil)
        } catch _ {
            let alert = UIAlertController(title: "Calendar Save Error", message: "Calendar could not be saved", preferredStyle: .alert)
            let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(OKAction)
            
            callingUIViewController.present(alert, animated: true, completion: nil)
        }
    }
    
    //delete a new calendar -> used only when user turns off calendar toggle in SettingsViewController
    func deleteCalendar( callingUIViewController: UIViewController ){
        
        let permissionsCheck = checkAuthorization(callingUIViewController: callingUIViewController)
        
        if permissionsCheck == false {
            print(">>>REMINDERS: we are still not authorized to make changes to calendar")
            return
        }
        
        // Get the calendar identifier we stored earlier.
        let calendarIdentifier = UserDefaults.standard.string(forKey: calendarIdKey)
        
        // Get the calendar associated with the stored calendar identifier.
        // Another way to get the calendar you're looking for.
        let calendar = eventStore.calendar(withIdentifier: calendarIdentifier!);
        
        if (calendar != nil) {
            // Delete our new Calendar.
            do {
                try eventStore.removeCalendar(calendar!, commit: true)
                print(">>>REMINDERS: calendar was successfully deleted")
            } catch _ {
                print(">>>REMINDERS: calendar was not deleted")
            }
        }
    }
    
    
    //============================================================================================
    
    //create a new calendar event
    func createCalendarEvent(callingUIViewController: UIViewController, inputTransaction: MyTransaction ){
        
        //check that we still have permission to make calendar changes
        let permissionsCheck = checkAuthorization(callingUIViewController: callingUIViewController)
        if permissionsCheck == false {
            print(">>>REMINDERS: we are still not authorized to make changes to calendar -> exiting func createBudgetCalendarEvent")
            return
        }
        
        //get calendar we should edit
        let calendarIdentifier = Account.calId()
        let calendar = eventStore.calendar(withIdentifier: calendarIdentifier)
        
        //check if inputTransaction is reoccuring,  create an EKRecurrenceRule if it is, and then attach this EKRecurrenceRule to the newEvent
        var newRule: EKRecurrenceRule? = nil
        if inputTransaction.isReoccuring == true {
            
            // !!! --- come back and change these static settings to match the inputTransaction properties
            let plusOneYear = 1
            let endDateInOneYear = Calendar.current.date(byAdding: .year, value: plusOneYear, to: inputTransaction.dueDate)
            let numDayOfMonth = thisDate.day( inputDate: inputTransaction.dueDate)
            newRule = createReoccuranceRule( occuranceNumericalDay: numDayOfMonth, endDate: endDateInOneYear! )
        }
        
        //check that calendar object exists and then try to save the new calendarEvent to it
        if (calendar != nil) {
            
            //create the calendar event object
            let inputDes = inputTransaction.desciption
            let inputDue = inputTransaction.dueDate
            //let newEvent = createCalendarEventObject( inputDescription: inputDes, inputDueDate: inputDue, inputCalendar: calendar!, inputRule: newRule!)
            /*
            do {
                try eventStore.save( newEvent, span: EKSpan.thisEvent)
                print(">>>REMINDERS: new reoccuring calendar event was created for MyTransaction \(inputTransaction.desciption)")
            } catch _ {
                print(">>>REMINDERS: new reoccuring calendar event was not created for MyTransaction \(inputTransaction.desciption)")
            }
            */
        }
    }
    
    
    //create a new calendar event
    func deleteCalendarEvent(callingUIViewController: UIViewController, callingReoccuringTransaction: MyTransaction ){
        
        let permissionsCheck = checkAuthorization(callingUIViewController: callingUIViewController)
        if permissionsCheck == false {
            print(">>>REMINDERS: we are still not authorized to make changes to calendar -> exiting func createBudgetCalendarEvent")
            return
        }
        
        // Get the calendar identifier we stored earlier.
        let calendarIdentifier = Account.calId()
        let calendar = eventStore.calendar(withIdentifier: calendarIdentifier)

        //find actual MyTransaction object and get its calendarID
        let actualMyTransaction = callingReoccuringTransaction.findMyTransactionLinkedToMyGoal(inputDescription: callingReoccuringTransaction.desciption)
        
        if (calendar != nil) {
            
            let eventID = actualMyTransaction.reminderID
            print("TESTING: actualMyTransaction.reminderID = \(actualMyTransaction.reminderID)")
            let calEventToDelete = eventStore.calendarItem(withIdentifier: eventID)
            
            do {
                try eventStore.remove(calEventToDelete as! EKEvent, span: EKSpan.futureEvents)
                print(">>>REMINDERS: reoccuring calendar event was deleted for MyTransaction \(callingReoccuringTransaction.desciption)")
            } catch _ {
                print(">>>REMINDERS: reoccuring calendar event was not deleted for MyTransaction \(callingReoccuringTransaction.desciption)")
            }
        }
    }
    
    
    
    
    func createCalendarEventObject( inputDescription: String, inputDueDate: Date, inputCalendar: EKCalendar, inputRule: EKRecurrenceRule) -> EKEvent{
        
        // Create calendar event object.
        let event = EKEvent(eventStore: eventStore)
        event.calendar = inputCalendar
        event.title = inputDescription
        event.startDate = inputDueDate
        event.endDate = (inputDueDate).addingTimeInterval(60 * 60) // Ending time is 1 hours from now.
        
        print("TEST: func createCalendarEventObject -> EKRecurrenceRule = \(EKRecurrenceRule)")
        if inputRule.isEqual(nil){
            return event
        }
        else {
            event.addRecurrenceRule(inputRule)
            return event
        }
    }
    
    func createReoccuranceRule( occuranceNumericalDay: Int, endDate: Date ) -> EKRecurrenceRule {
        
        let numericalDayOfMonth:NSNumber = occuranceNumericalDay as NSNumber
        let reoccuranceDate = EKRecurrenceRule( recurrenceWith: .monthly, //each month
            interval:       1,        //occurs every month
            daysOfTheWeek:  nil,
            daysOfTheMonth: [numericalDayOfMonth],
            monthsOfTheYear:nil,
            weeksOfTheYear: nil,
            daysOfTheYear:  nil,
            setPositions:   nil,
            end:            nil)
        return reoccuranceDate
    }
    
}//end of Reminders class






