//
//  ConvergeRecord.swift
//  Converge
//
//  Created by David (work) on 1/11/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//

import CoreData

public class Record: NSManagedObject {
    
    // MARK: - Configuration
    
    public class func IDAttributeName() -> String {
        return "id"
    }
    
    // MARK: -
    
    public class func entityName() -> String {
        
    }
    
    public class func entity(inManagedObjectContext context: NSManagedObjectContext) -> NSEntityDescription {
        
    }
    
    // MARK: - ID
    
    internal func configuredID() -> String {
        
    }
    
    internal func setConfiguredID(newConfiguredID: String) {
        
    }
    
    internal func hasConfiguredID() -> Bool {
        
    }
    
    internal class func hasConfiguredID(inContext context: NSManagedObjectContext) -> Bool {
        
    }
    
    // MARK: - Querying
    
    public class func recordForID(ID: AnyObject, context: NSManagedObjectContext) throws -> Record? {
        
    }
    
    public class func allRecords(sortedBy sortDescriptors: [NSSortDescriptor]?, context: NSManagedObjectContext) throws -> [Record]? {
        
    }
    
    public class func recordsWhere(conditions: Dictionary<String, AnyObject>, requireAll: Bool, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) throws -> [Record]? {
        
    }
    
    public class func recordsWhere(predicateString: String, arguments: [AnyObject], sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) throws -> [Record]? {
        
    }
    
    public func recordWhere(conditions: Dictionary<String, AnyObject>, requireAll: Bool, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int) throws -> [Record]? {
    }
    
    public func recordWhere(predicateString: String, arguments: [AnyObject], sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int) throws -> [Record]? {
        
    }
    
    public class func fetchedResultsControllerWhere(conditions: Dictionary<String, AnyObject>, requireAll: Bool, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchedResultsController {
        
    }
    
    public class func fetchedResultsControllerWhere(predicateString: String, arguments: [AnyObject], sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchedResultsController {
        
    }
    
    public class func fetchRequestWhere(conditions: Dictionary<String, AnyObject>, requireAll: Bool, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchRequest {
        
    }
    
    public class func fetchRequestWhere(predicateString: String, arguments: [AnyObject], sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchRequest {
        
    }
    
    public class func fetchRequest(withPredicate predicate: NSPredicate, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchRequest {
        
    }
    
    // MARK: -
    
    public func dictionary() -> Dictionary<String, AnyObject> {
        
    }
    
    // MARK: - Modifying
    
    public class func newRecord(inContext context: NSManagedObjectContext) -> Record {
        
    }
    
    public class func newRecord(withProperties properties: Dictionary<String, AnyObject>, inContext context: NSManagedObjectContext) throws -> Record {
        
    }
    
    public func copy(inContext context: NSManagedObjectContext) throws -> Record {
        
    }
    
    public class func deleteSet(set: NSMutableSet, context: NSManagedObjectContext) {
        
    }
    
    public class func deleteAll(inContext context: NSManagedObjectContext) throws {
        
    }
    
    // MARK: - Hybrid
    
    public class func newOrExistingRecord(withProperties properties: Dictionary<String, AnyObject>, inContext context: NSManagedObjectContext) throws -> Record {
        
    }
    
    // MARK: - Validating
    
    public class func classForAttribute(attribute: NSAttributeDescription) -> AnyClass {
        
    }
    
    public class func classForAttributeName(attributeName: String, context: NSManagedObjectContext) -> AnyClass {
        
    }
    
    public class func valueIsCorrectClass(value: AnyObject, forAttributeName attributeName: String, context: NSManagedObjectContext) -> Bool {
        
    }
    
    // MARK: - Relationship info
    
    public class func classForRelationshipName(relationshipName: String, context: NSManagedObjectContext) -> AnyClass {
        
    }
    
}
