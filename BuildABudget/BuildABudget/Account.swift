//
//  Account.swift
//  BuildABudget
//
//  Created by Ben Nguyen on 10/20/17.
//  Copyright © 2017 Ben Nguyen. All rights reserved.
//

import Foundation

class Account: NSObject {
    // Define keys for the values to store
    fileprivate static let kUserNameKey = "userName"
    fileprivate static let kFirstNameKey = "firstName"
    fileprivate static let kLastNameKey = "lastName"
    fileprivate static let kPassKey = "pass"
    fileprivate static let kCurrencyKey = "currency"
    fileprivate static let kCalIdKey = "calID"
    
    class func setUserName(_ userName:String) {
        UserDefaults.standard.set(userName, forKey: kUserNameKey)
        UserDefaults.standard.synchronize()
    }
    
    class func setFirstName(_ firstName:String) {
        UserDefaults.standard.set(firstName, forKey: kFirstNameKey)
        UserDefaults.standard.synchronize()
    }
    
    class func setLasttName(_ lastName:String) {
        UserDefaults.standard.set(lastName, forKey: kLastNameKey)
        UserDefaults.standard.synchronize()
    }
    
    class func setPass(_ pass:String) {
        UserDefaults.standard.set(pass, forKey: kPassKey)
        UserDefaults.standard.synchronize()
    }
    
    class func setCurrency(_ currency:String) {
        UserDefaults.standard.set(currency, forKey: kCurrencyKey)
        UserDefaults.standard.synchronize()
    }
    
    class func setCalId(_ calId:String) {
        UserDefaults.standard.set(calId, forKey: kCalIdKey)
        UserDefaults.standard.synchronize()
    }
    
    class func userName() -> String {
        return UserDefaults.standard.object(forKey: kUserNameKey) as! String
    }
    
    class func firstName() -> String {
        return UserDefaults.standard.object(forKey: kFirstNameKey) as! String
    }
    
    class func lastName() -> String {
        return UserDefaults.standard.object(forKey: kLastNameKey) as! String
    }
    
    class func pass() -> String {
        return UserDefaults.standard.object(forKey: kPassKey) as! String
    }
    
    class func currency() -> String {
        return UserDefaults.standard.object(forKey: kCurrencyKey) as! String
    }
    
    class func calId() -> String {
        return UserDefaults.standard.object(forKey: kCalIdKey) as! String
    }
}

