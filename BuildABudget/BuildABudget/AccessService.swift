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
    

    
}
