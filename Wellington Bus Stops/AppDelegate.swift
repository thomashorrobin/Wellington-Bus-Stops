//
//  AppDelegate.swift
//  Wellington Bus Stops
//
//  Created by Thomas Horrobin on 28/05/16.
//  Copyright © 2016 Wellington City Council API Extensions. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var departureBoardWindows = [NSWindowController]()
    var tablesToRefresh = [ITableDataRefreshable]()
    
    func refreshTableData() {
        for dataTable in tablesToRefresh {
            dataTable.refreshTableData()
        }
    }
    
    func openNewDepartureBoardWindow(sms: String) {
        let storyboard = NSStoryboard(name: "Main",bundle: nil)
        
        if let vc = storyboard.instantiateControllerWithIdentifier("departureBoard") as? DepartureBoardViewController{
            let newWindow = NSWindow(contentViewController: vc)
            newWindow.title = "Stop: " + sms
            newWindow.makeKeyAndOrderFront(self)
            let controller = NSWindowController(window: newWindow)
            departureBoardWindows.append(controller)
            controller.showWindow(self)
            vc.populateDepartureBoard(sms, savedToWidget: busStopExists(sms), kill: {() -> () in
                dispatch_async(dispatch_get_main_queue(), {
                    newWindow.close()
                    let alert = NSAlert()
                    alert.messageText = "Invalid Busstop Number"
                    alert.informativeText = "\(sms) isn't a known busstop number. Please try again."
                    alert.runModal()
                })
            })
            tablesToRefresh.append(vc)
        }
    }
    
    func addFromSms(sms: String){
        BusStopLatLng.getStop(sms, completion: {(busStop: BusStopLatLng) -> Void in
            self.saveBusStop(busStop, completetion: {(busStop: NSManagedObject) -> Void in
                self.refreshTableData()
            })
            }, error: invalidBusStopHandler)
    }
    
    func invalidBusStopHandler(sms: String) -> () {
        dispatch_async(dispatch_get_main_queue(), {
            let alert = NSAlert()
            alert.messageText = "Invalid Busstop Number"
            alert.informativeText = "\(sms) isn't a known busstop number. Please try again."
            alert.runModal()
        })
    }
    
    func saveBusStop(busStop: BusStopLatLng, completetion: (busStop: NSManagedObject) -> Void) {
        
        if busStopExists(busStop.sms) {
            print("Bus stop: \(busStop.sms) already exisits. Can't be duplicated")
            return
        }
        
        let entity =  NSEntityDescription.entityForName("BusStop",
                                                        inManagedObjectContext:managedObjectContext)
        
        let bs = NSManagedObject(entity: entity!,
                                 insertIntoManagedObjectContext: managedObjectContext)
        
        bs.setValue(busStop.name, forKey: "name")
        bs.setValue(busStop.sms, forKey: "sms")
        
        do {
            try managedObjectContext.save()
            completetion(busStop: bs)
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
    }
    
    func deleteBusStop(sms: String) {
        
        let fetchRequest = NSFetchRequest(entityName: "BusStop")
        
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            let managedObjects = results as! [NSManagedObject]
            for managedObject in managedObjects {
                if managedObject.valueForKey("sms") as! String == sms {
                    managedObjectContext.deleteObject(managedObject)
                }
            }
            try managedObjectContext.save()
            refreshTableData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
    
    func busStopExists(sms: String) -> Bool {
        let fetchRequest = NSFetchRequest(entityName: "BusStop")
        
        do {
            let results = try managedObjectContext.executeFetchRequest(fetchRequest)
            let managedObjects = results as! [NSManagedObject]
            for managedObject in managedObjects {
                if managedObject.valueForKey("sms") as! String == sms {
                    return true
                }
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
        return false
    }

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "wccapps.Wellington_Bus_Stops" in the user's Application Support directory.
        let urls = NSFileManager.defaultManager().containerURLForSecurityApplicationGroupIdentifier("6H77GT49V5.group.wccapps.bus_stop_data")
        let appSupportURL = urls!
        return appSupportURL.URLByAppendingPathComponent("6H77GT49V5.group.wccapps.bus_stop_data")
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("Wellington_Bus_Stops", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.) This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        let fileManager = NSFileManager.defaultManager()
        var failError: NSError? = nil
        var shouldFail = false
        var failureReason = "There was an error creating or loading the application's saved data."

        // Make sure the application files directory is there
        do {
            let properties = try self.applicationDocumentsDirectory.resourceValuesForKeys([NSURLIsDirectoryKey])
            if !properties[NSURLIsDirectoryKey]!.boolValue {
                failureReason = "Expected a folder to store application data, found a file \(self.applicationDocumentsDirectory.path)."
                shouldFail = true
            }
        } catch  {
            let nserror = error as NSError
            if nserror.code == NSFileReadNoSuchFileError {
                do {
                    try fileManager.createDirectoryAtPath(self.applicationDocumentsDirectory.path!, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    failError = nserror
                }
            } else {
                failError = nserror
            }
        }
        
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = nil
        if failError == nil {
            coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
            let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("CocoaAppCD.storedata")
            do {
                try coordinator!.addPersistentStoreWithType(NSXMLStoreType, configuration: nil, URL: url, options: nil)
            } catch {
                failError = error as NSError
            }
        }
        
        if shouldFail || (failError != nil) {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            if failError != nil {
                dict[NSUnderlyingErrorKey] = failError
            }
            let error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSApplication.sharedApplication().presentError(error)
            abort()
        } else {
            return coordinator!
        }
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving and Undo support

    @IBAction func saveAction(sender: AnyObject!) {
        // Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing before saving")
        }
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                NSApplication.sharedApplication().presentError(nserror)
            }
        }
    }

    func windowWillReturnUndoManager(window: NSWindow) -> NSUndoManager? {
        // Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
        return managedObjectContext.undoManager
    }

    func applicationShouldTerminate(sender: NSApplication) -> NSApplicationTerminateReply {
        // Save changes in the application's managed object context before the application terminates.
        
        if !managedObjectContext.commitEditing() {
            NSLog("\(NSStringFromClass(self.dynamicType)) unable to commit editing to terminate")
            return .TerminateCancel
        }
        
        if !managedObjectContext.hasChanges {
            return .TerminateNow
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            let nserror = error as NSError
            // Customize this code block to include application-specific recovery steps.
            let result = sender.presentError(nserror)
            if (result) {
                return .TerminateCancel
            }
            
            let question = NSLocalizedString("Could not save changes while quitting. Quit anyway?", comment: "Quit without saves error question message")
            let info = NSLocalizedString("Quitting now will lose any changes you have made since the last successful save", comment: "Quit without saves error question info");
            let quitButton = NSLocalizedString("Quit anyway", comment: "Quit anyway button title")
            let cancelButton = NSLocalizedString("Cancel", comment: "Cancel button title")
            let alert = NSAlert()
            alert.messageText = question
            alert.informativeText = info
            alert.addButtonWithTitle(quitButton)
            alert.addButtonWithTitle(cancelButton)
            
            let answer = alert.runModal()
            if answer == NSAlertFirstButtonReturn {
                return .TerminateCancel
            }
        }
        // If we got here, it is time to quit.
        return .TerminateNow
    }

}

