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
    
    //create a new calendar
    func createBudgetCalendar() {
        
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
    func deleteBudgetCalendar(){
        // Get the calendar identifier we stored earlier.
        let calendarIdentifier = UserDefaults.standard.string(forKey: calendarIdKey)
        
        // Get the calendar associated with the stored calendar identifier.
        // Another way to get the calendar you're looking for.
        let calendar = eventStore.calendar(withIdentifier: calendarIdentifier!);
        
        if (calendar != nil) {
            // Delete our new Calendar.
            do {
                try eventStore.removeCalendar(calendar!, commit: true)
                /*
                let alert = UIAlertController(title: "Calendar Deleted", message: "Calendar was successfully deleted", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                 */
                print(">>>REMINDERS: calendar was successfully deleted")
            } catch _ {
                /*
                let alert = UIAlertController(title: "Calendar Delete Error", message: "Calendar could not be deleted", preferredStyle: .alert)
                let OKAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(OKAction)
                self.present(alert, animated: true, completion: nil)
                */
                print(">>>REMINDERS: calendar was not deleted")
            }
        }
    }
    //create a new calendar event
    func createBudgetCalendarEvent(){
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
    func deleteBudgetCalendarEvent() {
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






