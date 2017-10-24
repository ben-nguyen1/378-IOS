//
//  AccessService.swift
//  BuildABudget
//
//  Created by chris on 10/22/17.
//  Copyright © 2017 Chris Cale. All rights reserved.
//
import Foundation
import CoreData

class AccessService {
    
    // Provide external access to this Singleton.
    static let access = AccessService()
    
    //class vars
    private var transactions: [NSManagedObject]!
    
    private var goals: [NSManagedObject]!
    
    private var budgets: [NSManagedObject]!
    
    
    
    
    
    //CoreData stuff
    private var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "BuildABudget")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    
    
    //getter/setter methods for to interface with CoreData
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
  
    
    // We want this class to be a Singleton.
    // To keep it that way, don't allow any code outside this class to instantiate an object of this type.
    private init() {}
    
    //========================================================================================================================================
    
    
    //Goal Methods:
    func retreiveAllGoals() {
        
        let managedContext = persistentContainer.viewContext
        var fetchedResults:[NSManagedObject]? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Goal")
        
        do {
            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        guard let results = fetchedResults else { return }
        goals = results
    }
    
    func saveGoal(input: MyTransaction) {
        
        let managedContext = persistentContainer.viewContext
        // Create the entity we want to save
        let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: managedContext)
        let record = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        // Set the attribute values
        record.setValue(input.datePaidOff, forKey: "datePaidOff")
        record.setValue(input.dueDate, forKey: "dueDate")
        record.setValue(input.initialInputDate, forKey: "occuranceDate")
        record.setValue(input.totalDue, forKey: "totalAmount")
        record.setValue(input.desciption, forKey: "transactionDescription")
        
        // Commit the changes.
        do {
            try managedContext.save()
            transactions.append(record)
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    
    func totalGoals() -> Int {
        return transactions.count
    }
    
    func getGoal(index:Int) -> MyTransaction {
        
        if index < transactions.count {
            let record = transactions[index]
            let rDescription =      record.value(forKey: "transactionDescription") as! String
            let rInitialInputDate = record.value(forKey: "occuranceDate") as! Date
            let rDueDate =          record.value(forKey: "dueDate") as! Date
            let rDatePaidOff =      record.value(forKey: "datePaidOff") as! Date
            let rBalance =          record.value(forKey: "currentAmount") as! Double
            let rTotalDue =         record.value(forKey: "totalAmount") as! Double
            let rIsReoccuring =     record.value(forKey: "isReoccuring") as! Bool
            
            return MyTransaction(description: rDescription,
                                 dueDate: rDueDate,
                                 totalDue: rTotalDue,
                                 isReoccuring: rIsReoccuring)
            
        } else {
            return MyTransaction()
        }
        
    }
    
    
    
    
    
    
    
    //========================================================================================================================================

    
    //Transaction Methods:
    func retreiveAllTransactions() {
        
        let managedContext = persistentContainer.viewContext
        var fetchedResults:[NSManagedObject]? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Transaction")
        
        do {
            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        guard let results = fetchedResults else { return }
        transactions = results
    }
    
    func saveTransaction(input: MyTransaction) {
        
        let managedContext = persistentContainer.viewContext
        // Create the entity we want to save
        let entity = NSEntityDescription.entity(forEntityName: "Transaction", in: managedContext)
        let record = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        // Set the attribute values
        record.setValue(input.datePaidOff, forKey: "datePaidOff")
        record.setValue(input.dueDate, forKey: "dueDate")
        record.setValue(input.initialInputDate, forKey: "occuranceDate")
        record.setValue(input.totalDue, forKey: "totalAmount")
        record.setValue(input.desciption, forKey: "transactionDescription")
        
        // Commit the changes.
        do {
            try managedContext.save()
            transactions.append(record)
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func totalTransactions() -> Int {
        return transactions.count
    }
    
    func getTransaction(index:Int) -> MyTransaction {
        
        if index < transactions.count {
            let record = transactions[index]
            let rDescription =      record.value(forKey: "transactionDescription") as! String
            let rInitialInputDate = record.value(forKey: "occuranceDate") as! Date
            let rDueDate =          record.value(forKey: "dueDate") as! Date
            let rDatePaidOff =      record.value(forKey: "datePaidOff") as! Date
            let rTotalDue =         record.value(forKey: "totalAmount") as! Double
            let rIsReoccuring =     record.value(forKey: "isReoccuring") as! Bool
            
            
            return MyTransaction(description: rDescription,
                                 initialInputDate: rInitialInputDate,
                                 dueDate: rDueDate,
                                 datePaidOff: rDatePaidOff,
                                 totalDue: rTotalDue,
                                 isReoccuring:rIsReoccuring)
        
        } else {
             return MyTransaction()
        }
    
    }
    //========================================================================================================================================

}


















