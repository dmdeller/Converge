//
//  ConvergeRecord.swift
//  Converge
//
//  Created by David (work) on 1/11/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//

import CoreData

public class Record: NSManagedObject {
    
    public static let ErrorDomain = "com.tripcraft.converge.record.error-domain"
    
    public enum Error: Int {
        case UnknownProperty
        case InvalidAttributeType
        case InvalidRelationshipClass
    }
    
    public enum ErrorUserInfoKey: String {
        case PropertyName = "com.tripcraft.converge.record.user-info.property-name"
        case ExpectedClass = "com.tripcraft.converge.record.user-info.expected-class"
        case ProvidedClass = "com.tripcraft.converge.record.user-info.actual-class"
    }
    
    // MARK: - Configuration
    
    public class func IDAttributeName() -> String {
        return "id"
    }
    
    // MARK: -
    
    public class func entityName() -> String {
        return NSStringFromClass(self)
    }
    
    public class func entity(inManagedObjectContext context: NSManagedObjectContext) -> NSEntityDescription {
        return NSEntityDescription.entityForName(entityName(), inManagedObjectContext: context)!
    }
    
    // MARK: - ID
    
    internal func configuredID() -> AnyObject? {
        return valueForKey(self.dynamicType.IDAttributeName())
    }
    
    internal func setConfiguredID(newConfiguredID: String) {
        setValue(newConfiguredID, forKey: self.dynamicType.IDAttributeName())
    }
    
    internal func hasConfiguredID() -> Bool {
        return self.dynamicType.hasConfiguredID(inContext: managedObjectContext!)
    }
    
    internal class func hasConfiguredID(inContext context: NSManagedObjectContext) -> Bool {
        if entity(inManagedObjectContext: context).propertiesByName.keys.contains(IDAttributeName()) {
            return true
        } else {
            return false
        }
    }
    
    // MARK: - Querying
    
    public class func recordForID(ID: AnyObject, context: NSManagedObjectContext) throws -> Record? {
        guard self.hasConfiguredID(inContext: context) else {
            fatalError("\(self.self): Does not have a configured ID")
        }
        
        guard valueIsCorrectClass(ID, forAttributeName: IDAttributeName(), context: context) else {
            let correctClass: AnyClass = classForAttributeName(IDAttributeName(), context: context)
            fatalError("\(self.self): Wrong class for ID attribute; expected \(correctClass), got \(ID.dynamicType) (\(ID))")
        }
        
        return try recordWhere([IDAttributeName(): ID], requireAll: true, sortBy: nil, context: context)
    }
    
    // FIXME: Should return [Self], but Swift doesn't allow this: http://stackoverflow.com/a/32701108/72581
    public class func allRecords(sortedBy sortDescriptors: [NSSortDescriptor]?, context: NSManagedObjectContext) throws -> [Record] {
        return try recordsWhere(Dictionary(), requireAll: true, sortBy: sortDescriptors, limit: 0, context: context)
    }
    
    /**
     * Given a list of attribute name and value pairs, returns any records that match.
     */
    public class func recordsWhere(conditions: [String: AnyObject?], requireAll: Bool, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) throws -> [Record] {
        
        let fetch = fetchRequestWhere(conditions, requireAll: requireAll, sortBy: sortDescriptors, limit: limit, context: context)
        return try context.executeFetchRequest(fetch) as! [Record]
    }
    
    public class func recordsWhere(predicateString: String, arguments: [AnyObject], sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) throws -> [Record] {
        
        let fetch = fetchRequestWhere(predicateString, arguments: arguments, sortBy: sortDescriptors, limit: limit, context: context)
        return try context.executeFetchRequest(fetch) as! [Record]
    }
    
    public class func recordWhere(conditions: [String: AnyObject?], requireAll: Bool, sortBy sortDescriptors: [NSSortDescriptor]?, context: NSManagedObjectContext) throws -> Record? {
        
        return try recordsWhere(conditions, requireAll: requireAll, sortBy: sortDescriptors, limit: 1, context: context).first
    }
    
    public class func recordWhere(predicateString: String, arguments: [AnyObject], sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) throws -> Record? {
        
        return try recordsWhere(predicateString, arguments: arguments, sortBy: sortDescriptors, limit: 1, context: context).first
    }
    
    public class func fetchedResultsControllerWhere(conditions: [String: AnyObject?], requireAll: Bool, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchedResultsController {
        
        let fetch = fetchRequestWhere(conditions, requireAll: requireAll, sortBy: sortDescriptors, limit: limit, context: context)
        return NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    public class func fetchedResultsControllerWhere(predicateString: String, arguments: [AnyObject], sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchedResultsController {
        
        let fetch = fetchRequestWhere(predicateString, arguments: arguments, sortBy: sortDescriptors, limit: limit, context: context)
        return NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
    }
    
    public class func fetchRequestWhere(conditions: [String: AnyObject?], requireAll: Bool, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchRequest {
        
        var compoundPredicate: NSPredicate?
        
        if conditions.count > 0 {
            
            var predicates: [NSPredicate] = []
            
            for (attributeName, value) in conditions {
                // NSPredicate.init(format, argumentArray) specifies argumentArray as [AnyObject], which means the array can't contain nil, even though that would be a perfectly cromulent predicate.
                // So, let's stick an NSNull in there like it's 1999
                let wrappedValue: AnyObject = {
                    if value == nil {
                        return NSNull()
                    } else {
                        return value!
                    }
                }()
                
                // This is a little bit crazy... you can't pass the attribute name in as an argument to predicateWithFormat:, so we're formatting the string twice...
                let predicate = NSPredicate(format: "\(attributeName) == %@", argumentArray: [wrappedValue])
                predicates.append(predicate)
            }
            
            if requireAll {
                compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            } else {
                compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: predicates)
            }
        }
        
        return fetchRequest(withPredicate: compoundPredicate, sortBy: sortDescriptors, limit: limit, context: context)
    }
    
    public class func fetchRequestWhere(predicateString: String, arguments: [AnyObject], sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchRequest {
        
        let predicate = NSPredicate(format: predicateString, argumentArray: arguments)
        return fetchRequest(withPredicate: predicate, sortBy: sortDescriptors, limit: limit, context: context)
    }
    
    public class func fetchRequest(withPredicate predicate: NSPredicate?, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchRequest {
        
        let fetch = NSFetchRequest()
        
        fetch.entity = entity(inManagedObjectContext: context)
        
        if predicate != nil {
            fetch.predicate = predicate!
        }
        
        if sortDescriptors != nil {
            fetch.sortDescriptors = sortDescriptors!
        }
        
        fetch.fetchLimit = limit
        
        return fetch
    }
    
    // MARK: -
    
    public func dictionary() -> [String: AnyObject?] {
        // FIXME: This is rather horrible
        return dictionaryWithValuesForKeys((entity.attributesByName as NSDictionary).allKeys as! [String])
    }
    
    // MARK: - Modifying
    
    public class func newRecord(inContext context: NSManagedObjectContext) -> Record {
        // FIXME: Couldn't this be self.init()?
        let newRecord = Record(entity: entity(inManagedObjectContext: context), insertIntoManagedObjectContext: context)
        
        context.insertObject(newRecord)
        
        return newRecord
    }
    
    public class func newRecord(withProperties properties: [String: AnyObject?], inContext context: NSManagedObjectContext) throws -> Record {
        
        let newRecord = self.newRecord(inContext: context)
        
        let allAttributeNames = newRecord.entity.attributesByName.keys
        let allRelationshipNames = newRecord.entity.relationshipsByName.keys
        
        for (key, value) in properties {
            if allAttributeNames.contains(key) {
                if valueIsCorrectClass(value, forAttributeName: key, context: context) {
                    newRecord.setValue(value, forKey: key)
                    
                } else {
                    let correctClass: AnyClass = classForAttributeName(key, context: context)
                    
                    let userInfo: [String: String] = [
                        NSLocalizedDescriptionKey: "The record could not be created",
                        NSLocalizedFailureReasonErrorKey: "The provided data was not valid.",
                        ErrorUserInfoKey.PropertyName.rawValue: key,
                        ErrorUserInfoKey.ExpectedClass.rawValue: NSStringFromClass(correctClass),
                        ErrorUserInfoKey.ProvidedClass.rawValue: NSStringFromClass(value!.dynamicType),
                    ]
                    
                    let error = NSError(domain: ErrorDomain, code: Error.InvalidAttributeType.rawValue, userInfo: userInfo)
                    
                    throw error
                }
            } else if allRelationshipNames.contains(key) {
                let relationshipClass: AnyClass = classForRelationshipName(key, context: context)
                
                if value == nil || value!.isKindOfClass(relationshipClass) {
                    newRecord.setValue(value, forKey: key)
                    
                } else {
                    let userInfo: [String: String] = [
                        NSLocalizedDescriptionKey: "The record could not be created",
                        NSLocalizedFailureReasonErrorKey: "The provided data was not valid.",
                        ErrorUserInfoKey.PropertyName.rawValue: key,
                        ErrorUserInfoKey.ExpectedClass.rawValue: NSStringFromClass(relationshipClass),
                        ErrorUserInfoKey.ProvidedClass.rawValue: NSStringFromClass(value!.dynamicType),
                    ]
                    
                    let error = NSError(domain: ErrorDomain, code: Error.InvalidRelationshipClass.rawValue, userInfo: userInfo)
                    
                    throw error
                }
                
            } else {
                let userInfo: [String: String] = [
                    NSLocalizedDescriptionKey: "The record could not be created",
                    NSLocalizedFailureReasonErrorKey: "The provided data was not valid.",
                    ErrorUserInfoKey.PropertyName.rawValue: key,
                ]
                
                let error = NSError(domain: ErrorDomain, code: Error.UnknownProperty.rawValue, userInfo: userInfo)
                
                throw error
            }
        }
        
        return newRecord
    }
    
    public func copy(inContext context: NSManagedObjectContext) throws -> Record {
        return try self.dynamicType.newRecord(withProperties: self.dictionary(), inContext: context)
    }
    
    public class func deleteSet(set: NSMutableSet, context: NSManagedObjectContext) {
        for record in set {
            context.deleteObject(record as! NSManagedObject)
        }
        
        set.removeAllObjects()
    }
    
    public class func deleteAll(inContext context: NSManagedObjectContext) throws {
        let records = try allRecords(sortedBy: nil, context: context)
        
        for record in records {
            context.deleteObject(record)
        }
    }
    
    // MARK: - Hybrid
    
    public class func newOrExistingRecord(withProperties properties: [String: AnyObject?], inContext context: NSManagedObjectContext) throws -> Record {
        
        var sortDescriptors: [NSSortDescriptor] = []
        for (key, _) in properties {
            sortDescriptors.append(NSSortDescriptor(key: key, ascending: true))
        }
        
        var record = try recordWhere(properties, requireAll: true, sortBy: sortDescriptors, context: context)
        
        if record == nil {
            record = try newRecord(withProperties: properties, inContext: context)
        }
        
        return record!
    }
    
    // MARK: - Validating
    
    public class func classForAttribute(attribute: NSAttributeDescription) -> AnyClass {
        
        switch attribute.attributeType {
        case .Integer16AttributeType,
        .Integer32AttributeType,
        .Integer64AttributeType,
        .DecimalAttributeType,
        .DoubleAttributeType,
        .FloatAttributeType,
        .BooleanAttributeType:
            return NSNumber.self
            
        case .StringAttributeType:
            return NSString.self
            
        case .DateAttributeType:
            return NSDate.self
            
        case .BinaryDataAttributeType:
            return NSData.self
            
        default:
            return AnyObject.self
        }
    }
    
    public class func classForAttributeName(attributeName: String, context: NSManagedObjectContext) -> AnyClass {
        
        let entity = self.entity(inManagedObjectContext: context)
        let attribute = entity.attributesByName[attributeName]
        
        guard attribute != nil else {
            fatalError("\(self.self): Attribute not found: \(attributeName) for entity: \(self.self)")
        }
        
        return classForAttribute(attribute!)
    }
    
    public class func valueIsCorrectClass(value: AnyObject?, forAttributeName attributeName: String, context: NSManagedObjectContext) -> Bool {
        
        let correctClass: AnyClass = classForAttributeName(attributeName, context: context)
        
        if value == nil {
            return true
            
        } else if value!.isKindOfClass(correctClass) {
            return true
            
        } else {
            return false
        }
    }
    
    // MARK: - Relationship info
    
    public class func classForRelationshipName(relationshipName: String, context: NSManagedObjectContext) -> AnyClass {
        
        let entity = self.entity(inManagedObjectContext: context)
        let relationships = entity.relationshipsByName
        let relationship = relationships[relationshipName]
        
        guard relationship != nil else {
            fatalError("\(self.self): Relationship not found: \(relationshipName) for entity: \(self.self)")
        }
        
        return NSClassFromString(relationship!.destinationEntity!.managedObjectClassName)!
    }
    
}
