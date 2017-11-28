//
//  MyCalendar.swift
//  BuildABudget
//
//  Created by chris on 10/24/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
import Foundation
//this class is used to make interacting with Date objects easier
class MyDate {
    
    //static let time = MyDate()//might need to remove this since it may not be needed
    static let dateConverter = MyDate()
    //calendar var
    let myCalendar = Calendar.current //this sets all our date, timezone, time, ect settings to the user's current phone settings.
    
    //date format var
    let myFormatter = DateFormatter()
    
    func day( inputDate: Date) -> Int{
        
        let thisDay = myCalendar.dateComponents([.day], from: inputDate)
        return thisDay.day!
    }
    
    func month( inputDate: Date) -> Int{
        let thisDay = myCalendar.dateComponents([.month], from: inputDate)
        return thisDay.month!
    }
    
    func year( inputDate: Date) -> Int{
        let thisDay = myCalendar.dateComponents([.year], from: inputDate)
        return thisDay.year!
    }
    
    func hour( inputDate: Date) -> Int?{
        let thisDay = myCalendar.dateComponents([.hour], from: inputDate)
        return thisDay.day!
    }
    
    func minute( inputDate: Date) -> Int?{
        let thisDay = myCalendar.dateComponents([.minute], from: inputDate)
        return thisDay.minute!
    }
    
    //used to set the MyTransaction.datePaidOff attribute to yesterday -> this signifies that the amount has not yet been paid.
    func setToYesterday( today:Date ) -> Date{
        
        let yesterday = myCalendar.date(byAdding: .day, value: -1, to: today)!
        return yesterday
    }
    
    func makeDate(inputDay: Int, inputMonth: Int, inputYear: Int, inputMinute: Int, inputHour: Int) -> Date{
        
        var components = DateComponents()
        components.day = inputDay
        components.month = inputMonth
        components.year = inputYear
        components.minute = inputMinute
        components.hour = inputHour
        
        return myCalendar.date(from: components)!
    }
    
    func makeDateMMDDYYYY(inputDay: Int, inputMonth: Int, inputYear: Int) -> Date{
        
        var components = DateComponents()
        components.day = inputDay
        components.month = inputMonth
        components.year = inputYear
        
        return myCalendar.date(from: components)!
    }
    
    func makeDateSetToDay28(inputMonth: Int, inputYear: Int) -> Date{
        
        var components = DateComponents()
        components.day = 28
        components.month = inputMonth
        components.year = inputYear
        
        return myCalendar.date(from: components)!
    }
    
    func dateDifferenceInDays(inputStartDate:Date, inputEndDate:Date) -> Int {
        let numDays = myCalendar.dateComponents([.day], from: inputStartDate, to: inputEndDate)
        return numDays.day!
    }
    
    func getDateXNumDaysFromNow(inputStartDate:Date, inputXNumDays: Int) -> Date {
        return myCalendar.date(byAdding: .day, value: inputXNumDays, to: inputStartDate)!
    }
    
    func stringToDate(inputString: String) -> Date {//this method will return a Date object from any string that has the correct format else it returns yesterday's date as a sign of error
        
        myFormatter.dateFormat = "MM/dd/yyyy"
        if let testDate = myFormatter.date(from: inputString) {
            return testDate
        }
        else {
            
            print("bad date format encountered: \(inputString) --> setting date to yesterday")
            return MyDate.dateConverter.setToYesterday(today: Date())
        }
        
    }
    
    func dateToString(inputDate: Date) -> String {
        myFormatter.dateFormat = "MM/dd/yyyy"
        return myFormatter.string(from: inputDate)
    }
    
    func shortDateToString(inputDate: Date) -> String {
        myFormatter.dateFormat = "MM/dd"
        return myFormatter.string(from: inputDate)
    }
    
    func dateToDashedString(inputDate: Date) -> String {
        myFormatter.dateFormat = "MM-dd-yyyy"
        return myFormatter.string(from: inputDate)
    }
    
    func getTimeZone() -> TimeZone{
        return myCalendar.timeZone
    }
    
    func isValidMMDDYYYYFormat(inputDateString: String?) -> Bool {
        
        let currentDate = Date()
        //let yesterday = self.setToYesterday(today: Date())
        let inputDate = self.stringToDate(inputString: inputDateString!)
        
        //checkes if the stringToDate function set inputDate to yesterday's date because the string was
        //not a valid Date format or if the inputDateString was a valid string but was set to a date in
        //the past
        if currentDate > inputDate {
            print("current Date -> output: \(currentDate)")
            print("current Date -> output: \(inputDate)")
            return false
        }
        
        return true
    }
 
    //Default initializer
    init() { }
    
}

























