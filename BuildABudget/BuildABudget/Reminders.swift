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
    
    let eventStore = EKEventStore();
    let calendarIdKey = "BuildABudgetCalendar"
    let calendarTitle = "My Budget"
    static let cal = Reminders()
    
    //check if authorized to access calendar
    func checkAuthorization( callingUIViewController: UIViewController ) -> Bool{
        
        let status = EKEventStore.authorizationStatus(for: .event)
        
        switch (status) {
        case .notDetermined:
            // This happens on first-run.
            //requestAccessToCalendar()
            print(">>>REMINDERS: DENYED")
            needPermission(callingUIViewController: callingUIViewController)
            return false
        case .authorized:
            // Ok to show the calendars in the table view.
            //showCalendars()
            print(">>>REMINDERS: SHOWING CAL")
            return true
        case .restricted, .denied:
            // Help the user give us permission to access the calendar.
            needPermission(callingUIViewController: callingUIViewController)
            return false
        }
        
    }
    
    func needPermission( callingUIViewController: UIViewController ) {
        // Display an alert controller, telling the user what we need.
        DispatchQueue.main.async(execute: {
            let alertController = UIAlertController(title: "Calendar Access", message: "You need to enable access to the calendar. Touch Ok to go to the setting.", preferredStyle: UIAlertControllerStyle.alert)
            
            let CancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel) { (action:UIAlertAction) in
            }
            alertController.addAction(CancelAction)
            
            let OKAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (action:UIAlertAction) in
                // Help the user give us permission to access the calendar, by navigating them to the relevant setting.
                let openSettingsUrl = URL(string: UIApplicationOpenSettingsURLString)
                UIApplication.shared.openURL(openSettingsUrl!)
            }
            alertController.addAction(OKAction)
            print(">>>REMINDERS: SHOULD LAUNCH UIALERT WINDOW HERE")
            //self.present(alertController, animated: true, completion:nil)
        })
    }
    
    //create a new calendar
    func createBudgetCalendar( callingUIViewController: UIViewController ) {
        
        let permissionsCheck = checkAuthorization(callingUIViewController: callingUIViewController)
        
        if permissionsCheck == false {
            print(">>>REMINDERS: we are still not authorized to make changes to calendar")
            return
        }
        
        // Setup new calendar
        let budgetCalendar = EKCalendar(for: .event, eventStore: eventStore)
        budgetCalendar.title = calendarTitle
        
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
            filteredCalendarList = sourcesInEventStore.filter{
                (source: EKSource) -> Bool in
                source.sourceType == .calDAV
            }
        }
        budgetCalendar.source = filteredCalendarList.first!
        
        
        // Save the calendar using the Event Store instance
        do {
            try eventStore.saveCalendar(budgetCalendar, commit: true)
            
            // Store the calendar id locally. To allow us to get this calendar later.
            UserDefaults.standard.set(budgetCalendar.calendarIdentifier, forKey: calendarIdKey)
            print(">>>REMINDERS: calendar was successfully saved")
        } catch _ {
            print(">>>REMINDERS: calendar was not saved")
        }
    }
    
    
    //delete a new calendar
    func deleteBudgetCalendar( callingUIViewController: UIViewController ){
        
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
    //create a new calendar event
    func createBudgetCalendarEvent(callingUIViewController: UIViewController ){
        
        let permissionsCheck = checkAuthorization(callingUIViewController: callingUIViewController)
        
        if permissionsCheck == false {
            print(">>>REMINDERS: we are still not authorized to make changes to calendar")
            return
        }
        
        let calendars = eventStore.calendars(for: EKEntityType.event)
        
        // Iterate through the calendars, looking for our new calendar.
        // One way to get the calendar you're looking for.
        for calendar in calendars {
            if calendar.title == calendarTitle {
                // Starting time is now.
                let startDate = Date()
                // Ending time is 2 hours from now.
                let endDate = startDate.addingTimeInterval(2 * 60 * 60)
                
                // Create calendar event object.
                let event = EKEvent(eventStore: eventStore)
                event.calendar = calendar
                event.title = "New Meeting"
                event.startDate = startDate
                event.endDate = endDate
                
                // Save the event in our new calendar.
                do {
                    try eventStore.save(event, span: EKSpan.thisEvent)
                    print(">>>REMINDERS: calendar event was created")
                } catch _ {
                    print(">>>REMINDERS: calendar event was not created")
                }
            }
        }
    }
    
    //delete a new calendar event
    func deleteBudgetCalendarEvent(callingUIViewController: UIViewController) {
        
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
                print(">>>REMINDERS: calendar event was deleted")
            } catch _ {
                print(">>>REMINDERS: calendar event was not deleted")
            }
        }
    }
    
}//end of Reminders class






