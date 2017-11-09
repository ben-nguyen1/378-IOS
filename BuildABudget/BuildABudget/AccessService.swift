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
    private var transactions: [NSManagedObject]! = []
    private var goals: [NSManagedObject]! = []
    private var budgets: [NSManagedObject]! = []
    
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
    
    func saveGoal(input: MyGoal) {
        
        let managedContext = persistentContainer.viewContext
        // Create the entity we want to save
        let entity = NSEntityDescription.entity(forEntityName: "Goal", in: managedContext)
        let record = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        //test values received by printing them out
        print("============================================")
        print("AccessService: Starting save process -> goals count = \(goals.count)")
        print("contributionList = \(input.allContributions.count)")
        print("goalDescription = \(input.desciption)")
        print("monthlyContributionAmount = \(input.monthlyContribution)")
        print("startDate = \(input.startDate)")
        print("targetDate = \(input.targetDate)")
        print("targetAmount = \(input.targetAmount)")
        print("============================================")
        
        // Set the attribute values
        record.setValue(input.allContributions,     forKey: "contributionList")
        record.setValue(input.desciption,           forKey: "goalDescription")
        record.setValue(input.monthlyContribution,  forKey: "monthlyContributionAmount")
        record.setValue(input.startDate,            forKey: "startDate")
        record.setValue(input.targetDate,           forKey: "targetDate")
        record.setValue(input.targetAmount,         forKey: "targetAmount")
        
        // Commit the changes.
        do {
            try managedContext.save()
            goals.append(record)
            print("AccessService: Successful save -> goals count = \(goals.count)")
            print("\nCheck against this CoreDate Record:\n\(record)")
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func totalGoals() -> Int {
        return goals.count
    }
    
    func getGoal(index:Int) -> MyGoal {
        
        if index < transactions.count {
            
            let record = goals[index]
            let rContributionList          = record.value(forKey: "contributionList") as! [MyTransaction]
            let rDescription               = record.value(forKey: "goalDescription") as! String
            let rMonthlyContributionAmount = record.value(forKey: "monthlyContributionAmount") as! Double
            let rStartDate                 = record.value(forKey: "startDate") as! Date
            let rTargetDate                = record.value(forKey: "targetDate") as! Date
            let rTargetAmount              = record.value(forKey: "targetAmount") as! Double
            
            return MyGoal(  contributionList:    rContributionList,
                            description:         rDescription,
                            monthlyContribution: rMonthlyContributionAmount,
                            startDate:           rStartDate,
                            targetDate:          rTargetDate,
                            targetAmount:        rMonthlyContributionAmount )
         } else {
            return MyGoal()
         }
        
    }
    
    func deleteGoal(input: MyGoal){
        let managedContext = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Goal> = Goal.fetchRequest()
        
        do {
            let goalArray = try managedContext.fetch(fetchRequest)
            
            for goal in goalArray as [NSManagedObject] {
                // Delete if the object is a match
                if (input.desciption            == goal.value(forKey: "goalDescription") as! String &&
                    input.startDate             == goal.value(forKey: "startDate") as! Date &&
                    input.targetDate            == goal.value(forKey: "targetDate") as! Date &&
                    input.monthlyContribution   == goal.value(forKey: "monthlyContributionAmount") as! Double &&
                    input.targetAmount          == goal.value(forKey: "targetAmount") as! Double){
                        context.delete(goal)
                }
            }
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        } catch {
            print("Error with request: \(error)")
        }
        
        // Update transaction array
        self.retreiveAllGoals()
    }
    
    
    
    //Transaction Methods:
    func retreiveAllTransactions() {
        
        print("\n>>> retrieiveAllTransactions count  before = \(totalTransactions())\n")
        
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Transaction")
        var fetchedResults:[NSManagedObject]? = nil
        
        do {
            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        guard let results = fetchedResults else { return }
        transactions = results
        print("\n>>> retrieiveAllTransactions count after = \(totalTransactions())\n")
        //printAllTransactions() <--- diagnostic test to check that all transactions were readable
    }
    
    func deleteTransaction(input: MyTransaction) {
        let managedContext = persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        
        do {
            let transactionArray = try managedContext.fetch(fetchRequest)
            
            for transaction in transactionArray as [NSManagedObject] {
                // Delete if the object is a match
                if (input.datePaidOff == transaction.value(forKey: "datePaidOff") as! Date &&
                input.dueDate == transaction.value(forKey: "dueDate") as! Date &&
                input.initialInputDate == transaction.value(forKey: "occuranceDate") as! Date &&
                input.totalDue == transaction.value(forKey: "totalAmount") as! Double &&
                input.desciption == transaction.value(forKey: "transactionDescription") as! String &&
                input.isIncome == transaction.value(forKey: "isIncome") as! Bool &&
                input.isReoccuring == transaction.value(forKey: "isReoccuring") as! Bool) {
                    context.delete(transaction)
                }
            }
            
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        } catch {
            print("Error with request: \(error)")
        }
        
        // Update transaction array
        self.retreiveAllTransactions()
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
        record.setValue(input.isIncome, forKey: "isIncome")
        record.setValue(input.isReoccuring, forKey: "isReoccuring")
        
        //test values received by printing them out
        print("============================================")
        print("\n>>> number of transactions before = \(totalTransactions())\n")
        
        print("Description = \(input.desciption)")
        print("InitialDate = \(input.initialInputDate)")
        print("DueDate = \(input.dueDate)")
        print("DatePaidOff = \(input.datePaidOff)")
        print("TotalDue = \(input.totalDue)")
        print("IsReoccuring = \(input.isReoccuring)")
        print("IsIncome = \(input.isIncome)")
        
        print("\n\(record)")
        
        print("============================================")
        
        // Commit the changes.
        do {
            try managedContext.save() //save to CoreDate
            
            transactions.append(record) //append the transactions array with this new NSManagedObject
            print("\n>>> number of transactions before = \(totalTransactions())\n")
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
            let rDescription =      record.value(forKey: "transactionDescription") as! String//
            let rInitialInputDate = record.value(forKey: "occuranceDate") as! Date//
            let rDueDate =          record.value(forKey: "dueDate") as! Date//
            let rDatePaidOff =      record.value(forKey: "datePaidOff") as! Date//
            let rTotalDue =         record.value(forKey: "totalAmount") as! Double//
            let rIsReoccuring =     record.value(forKey: "isReoccuring") as! Bool//
            let rIsIncome =         record.value(forKey: "isIncome") as! Bool//
            
            return MyTransaction(description:       rDescription,
                                 initialInputDate:  rInitialInputDate,
                                 dueDate:           rDueDate,
                                 datePaidOff:       rDatePaidOff,
                                 totalDue:          rTotalDue,
                                 isReoccuring:      rIsReoccuring,
                                 isIncome:          rIsIncome)
        } else {
            return MyTransaction()
        }
        
    }
    
    func printAllTransactions() {
        
        var i = 0
        var limit = totalTransactions()
        
        for i in 0..<limit {
            print("ITEM => \(getTransaction(index: i).desciption) , \(getTransaction(index: i).date) , \(getTransaction(index: i).isIncome ) , \(getTransaction(index: i).totalDue)")
        }
    }
    
    //Budget Methods:
    func retreiveAllBudgets() {
        
        let managedContext = persistentContainer.viewContext
        var fetchedResults:[NSManagedObject]? = nil
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Budget")
        
        do {
            try fetchedResults = managedContext.fetch(fetchRequest) as? [NSManagedObject]
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
        
        guard let results = fetchedResults else { return }
        budgets = results
    }
    
    func saveBudget(input: MyBudget) {
        
        let managedContext = persistentContainer.viewContext
        // Create the entity we want to save
        let entity = NSEntityDescription.entity(forEntityName: "Budget", in: managedContext)
        let record = NSManagedObject(entity: entity!, insertInto:managedContext)
        
        // Set the attribute values
        record.setValue(input.desciption, forKey: "budgetDescription")
        record.setValue(input.startDate, forKey: "startDate")
        record.setValue(input.endDate, forKey: "endDate")
        record.setValue(input.allExpenses, forKey: "expenseSources")
        record.setValue(input.allIncome, forKey: "incomeSources")
        
        // Commit the changes.
        do {
            try managedContext.save()
            budgets.append(record)
        } catch {
            let nserror = error as NSError
            NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            abort()
        }
    }
    
    func totalBudgets() -> Int {
        return budgets.count
    }
    
    func getBudget(index:Int) -> MyBudget {//we should only call on getBudget(0) because for the Alpha Release we will only use one possible Budget
        if (budgets == nil) {
            print("budgets is null")
        }
        
        if (budgets != nil) && index < budgets.count {
            let record = budgets[index]
            let rDescription =      record.value(forKey: "budgetDescription") as! String
            let rStartDate = record.value(forKey: "startDate") as! Date
            let rEndDate =          record.value(forKey: "endDate") as! Date
            let rExpenseSources =      record.value(forKey: "expenseSources") as! [MyTransaction]
            let rIncomeSources =         record.value(forKey: "incomeSources") as! [MyTransaction]
            
            
            return MyBudget(description: rDescription,
                            startDate: rStartDate,
                            endDate: rEndDate,
                            expenseSources: rExpenseSources,
                            incomeSources: rIncomeSources)
            
        } else {
            return MyBudget()//returns a blank budget when we first open the BudgetViewController
        }
        
    }
    
}


















