//
//  Record+Mapping.swift
//  Converge
//
//  Created by David (work) on 1/12/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//

import Foundation
import CoreData
import Cent

extension Record {
    
    public typealias OurPropertyName = String
    
    // TODO: This type should either be a String or an Array<String>. Is there some clever way to express this in Swift?
    public typealias ProviderPropertyName = AnyObject
    
    public typealias ProviderDataMap = [OurPropertyName: ProviderPropertyName]
    public typealias PropertyValue = AnyObject
    public typealias HTTPParameters = [String: String?]
    
    // MARK: - Configuration
    
    /**
    * Override if provider's ID has a different name (e.g. public_id)
    */
    public class func providerIDAttributeName() -> ProviderPropertyName {
        let mappedID = attributeMap()[IDAttributeName()]
        
        if mappedID != nil {
            return mappedID!
        } else {
            return "id"
        }
    }
    
    /**
     * Relative URL path to fetch JSON data for a collection of records of this class from the provider.
     */
    public class func collectionURLPath(HTTPMethod HTTPMethod: String, parameters: HTTPParameters?) -> String {
        let camelCaseTransformer = NSValueTransformer(forName: TTTCamelCaseStringTransformerName)!
        let snakeCaseTransformer = NSValueTransformer(forName: TTTSnakeCaseStringTransformerName)!
        
        return "/\(TTTStringInflector.defaultInflector().pluralize(snakeCaseTransformer.transformedValue(camelCaseTransformer.reverseTransformedValue(NSStringFromClass(self.self))) as! String))"
    }
    
    /**
     * Relative URL path to fetch JSON data for a record of this class from the provider.
     */
    public class func URLPath(forID ID: PropertyValue, HTTPMethod: String, parameters: HTTPParameters?) -> String {
        let camelCaseTransformer = NSValueTransformer(forName: TTTCamelCaseStringTransformerName)!
        let snakeCaseTransformer = NSValueTransformer(forName: TTTSnakeCaseStringTransformerName)!
        
        return "/\(TTTStringInflector.defaultInflector().pluralize(snakeCaseTransformer.transformedValue(camelCaseTransformer.reverseTransformedValue(NSStringFromClass(self.self))) as! String))/\(ID)"
    }
    
    /**
     * Relative URL path to fetch JSON data for a record of this class from the provider.
     */
    public func URLPath(HTTPMethod HTTPMethod: String, parameters: HTTPParameters?) -> String {
        guard configuredID() != nil else {
            fatalError("\(self.dynamicType): Cannot determine URL path for record with nil ID")
        }
        
        return self.dynamicType.URLPath(forID: configuredID()!, HTTPMethod: HTTPMethod, parameters: parameters)
    }
    
    /**
     * Maps provider attributes to Core Data attributes
     *
     * If not specified, TCKRecord will try to figure out the mapping automatically, first by looking for identical names, then by looking for snake_cased equivalents of llamaCased names.
     */
    public class func attributeMap() -> ProviderDataMap {
        return Dictionary()
    }
    
    /**
     * Maps provider foreign key attributes to Core Data relationships (if any)
     *
     * This is similar to relationshipMap, but it is expected that the provider will give us only a key instead of the full object.
     */
    public class func foreignKeyMap() -> ProviderDataMap {
        return Dictionary()
    }
    
    /**
     * Maps provider collections to Core Data relationships (if any)
     */
    public class func relationshipMap() -> ProviderDataMap {
        return Dictionary()
    }
    
    // MARK: - Mapping logic
    
    internal class func attributeMap(forProviderPropertyNames providerPropertyNames: [ProviderPropertyName], context: NSManagedObjectContext) -> ProviderDataMap {
        
        var map = self.map(forProviderPropertyNames: providerPropertyNames, configuredMap: attributeMap(),
            automaticNameBlock: { (providerPropertyName) -> OurPropertyName? in
                return self.inferredAttributeName(forProviderPropertyName: providerPropertyName, context: context)
            }, context: context)
        
        map[IDAttributeName()] = providerIDAttributeName()
        
        return map
    }
    
    internal class func foreignKeyMap(forProviderPropertyNames providerPropertyNames: [ProviderPropertyName], context: NSManagedObjectContext) -> ProviderDataMap {
        
        return map(forProviderPropertyNames: providerPropertyNames, configuredMap: foreignKeyMap(),
            automaticNameBlock: { (providerPropertyName) -> OurPropertyName? in
                return inferredRelationshipName(forProviderForeignKeyName: providerPropertyName, context: context)
            }, context: context)
    }
    
    internal class func relationshipMap(forProviderPropertyNames providerPropertyNames: [ProviderPropertyName], context: NSManagedObjectContext) -> ProviderDataMap {
        
        return map(forProviderPropertyNames: providerPropertyNames, configuredMap: relationshipMap(),
            automaticNameBlock: { (providerPropertyName) -> OurPropertyName? in
                return inferredRelationshipName(forProviderRelationshipName: providerPropertyName, context: context)
            }, context: context)
    }
    
    private class func map(forProviderPropertyNames providerPropertyNames: [ProviderPropertyName], configuredMap: ProviderDataMap, automaticNameBlock: (providerPropertyName: ProviderPropertyName) -> OurPropertyName?, context: NSManagedObjectContext) -> ProviderDataMap {
        
        var map: [OurPropertyName: ProviderPropertyName] = Dictionary()
        
        for providerPropertyName in providerPropertyNames {
            let ourName = automaticNameBlock(providerPropertyName: providerPropertyName)
            
            if ourName != nil && map[ourName!] == nil {
                map[ourName!] = providerPropertyName
            }
        }
        
        // Explicitly configured mappings override automatically inferred ones
        map.merge(configuredMap)
        
        return map
    }
    
    private class func attributeName(forProviderPropertyName providerPropertyName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
        let ourAttributeName = (attributeMap() as NSDictionary).allKeysForObject(providerPropertyName).first()
        if ourAttributeName != nil {
            return ourAttributeName as? OurPropertyName
        }
        
        return inferredAttributeName(forProviderPropertyName: providerPropertyName, context: context)
    }
    
    private class func inferredAttributeName(forProviderPropertyName providerPropertyName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
        let entity = self.entity(inManagedObjectContext: context)
        return similarName(providerPropertyName, inNames: Array(entity.attributesByName.keys))
    }
    
    private class func relationshipName(forProviderForeignKeyName providerForeignKeyName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
        let ourRelationshipName = (foreignKeyMap() as NSDictionary).allKeysForObject(providerForeignKeyName).first()
        if ourRelationshipName != nil {
            return (ourRelationshipName as! OurPropertyName)
        }
        
        return inferredRelationshipName(forProviderForeignKeyName: providerForeignKeyName, context: context)
    }
    
    private class func inferredRelationshipName(forProviderForeignKeyName providerForeignKeyName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
        let IDRegEx = "(_id|ID|Id)s?$"
        guard (providerForeignKeyName is String) && (providerForeignKeyName as! String =~ IDRegEx) else {
            return nil
        }
        
        let isPlural = ((providerForeignKeyName as! String) =~ "s$")
        
        let regExObj = try! NSRegularExpression(pattern: IDRegEx, options: [])
        
        // FIXME: painful. I just need to do a regex replace 😩
        var providerRelationshipNameObjC: NSMutableString = (providerForeignKeyName as! NSString).mutableCopy() as! NSMutableString
        regExObj.replaceMatchesInString(providerRelationshipNameObjC, options: [], range: NSRange(location: 0, length: ((providerForeignKeyName as! String).length - 1)), withTemplate: "")
        
        var providerRelationshipName = String(providerRelationshipNameObjC)
        
        if isPlural {
            providerRelationshipName = TTTStringInflector.defaultInflector().pluralize(providerRelationshipName as String)
        }
        
        return inferredRelationshipName(forProviderRelationshipName: providerRelationshipName, context: context)
    }
    
    private class func relationshipName(forProviderRelationshipName providerRelationshipName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
        let ourRelationshipName = (relationshipMap() as NSDictionary).allKeysForObject(providerRelationshipName).first()
        if ourRelationshipName != nil {
            return (ourRelationshipName as! OurPropertyName)
        }
        
        return inferredRelationshipName(forProviderRelationshipName: providerRelationshipName, context: context)
    }
    
    private class func inferredRelationshipName(forProviderRelationshipName providerRelationshipName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
        let entity = self.entity(inManagedObjectContext: context)
        return similarName(providerRelationshipName, inNames: Array(entity.relationshipsByName.keys))
    }
    
    private class func similarName(providerName: ProviderPropertyName, inNames ourNames: [OurPropertyName]) -> OurPropertyName? {
        
        guard providerName is OurPropertyName else {
            return nil
        }
        
        guard (ourNameTransformer() != nil) && (providerNameTransformer() != nil) else {
            return nil
        }
        
        if ourNames.contains(providerName as! OurPropertyName) {
            return (providerName as! OurPropertyName)
        }
        
        let transformedName: OurPropertyName? = ourNameTransformer()!.transformedValue(providerNameTransformer()!.reverseTransformedValue(providerName)) as? OurPropertyName
        
        if transformedName != nil && ourNames.contains(transformedName!) {
            return (providerName as! OurPropertyName)
        }
        
        return nil
    }
    
    public class func providerNameTransformer() -> NSValueTransformer? {
        
        return NSValueTransformer(forName: TTTSnakeCaseStringTransformerName)
    }
    
    public class func ourNameTransformer() -> NSValueTransformer? {
        
        return NSValueTransformer(forName: TTTLlamaCaseStringTransformerName)
    }
    
    private class func inferredProviderForeignKeyName(forRelationship relationship: NSRelationshipDescription) -> ProviderPropertyName? {
        
        guard (ourNameTransformer() != nil) && (providerNameTransformer() != nil) else {
            return nil
        }
        
        let suffix: String = {
            if relationship.toMany {
                return "ids"
            } else {
                return "id"
            }
        }()
        
        let ourName = relationship.name
        let providerName = providerNameTransformer()!.transformedValue("\(ourNameTransformer()!.reverseTransformedValue(ourName)) \(suffix)")
        
        return providerName
    }
    
    // MARK: - Querying based on mappings
    
    public class func recordsFromQuery(params: HTTPParameters?, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) throws -> [Record] {
        
        let fetch = try fetchRequestWithQuery(params, sortBy: sortDescriptors, limit: limit, context: context)
        
        return try context.executeFetchRequest(fetch) as! [Record]
    }
    
    public class func fetchRequestWithQuery(params: HTTPParameters?, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) throws -> NSFetchRequest {
        
        return fetchRequest(withPredicate: try predicateForQuery(params, context: context), sortBy: sortDescriptors, limit: limit, context: context)
    }
    
    /**
     * Transforms a set of query parameters into an NSPredicate that can be used for querying.
     */
    internal class func predicateForQuery(params: HTTPParameters?, context: NSManagedObjectContext) throws -> NSPredicate? {
        
        guard params != nil else {
            return nil
        }
        
        var predicates: [NSPredicate] = []
        
        let attributeMap = self.attributeMap(forProviderPropertyNames: Array(params!.keys), context: context)
        let foreignKeyMap = self.foreignKeyMap(forProviderPropertyNames: Array(params!.keys), context: context)
        
        let entity = self.entity(inManagedObjectContext: context)
        let relationships = entity.relationshipsByName
        
        for (ourName, providerName) in attributeMap {
            if providerName is String && params!.keys.contains(providerName as! String) {
                let value: String? = params![providerName as! String]!
                let predicate = NSPredicate(format: "\(ourName) == %@", argumentArray: [value])
                predicates.append(predicate)
            }
        }
        
        for (ourName, providerName) in foreignKeyMap {
            if providerName is String && params!.keys.contains(providerName as! String) {
                let foreignID = params![providerName as! String]!
                let foreignClass = classForRelationshipName(ourName, context: context)
                
                let value = try foreignClass.recordForID(foreignID!, context: context)
                
                if value != nil {
                    let relationship = relationships[ourName]!
                    
                    let predicate: NSPredicate = {
                        if relationship.toMany {
                            return NSPredicate(format: "%@ IN \(ourName)", argumentArray: [value])
                        } else {
                            return NSPredicate(format: "\(ourName) == %@", argumentArray: [value])
                        }
                    }()
                    
                    predicates.append(predicate)
                    
                } else {
                    NSLog("\(self.dynamicType): unable to transform query param into predicate because \(ourName) with id \(foreignID) was not found, query: \(params)")
                }
            }
        }
        
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
    }
    
    // MARK: - Relationship info
    
    /*
    * Given a relationship on this class, returns the name of the provider's foreign key that represents this relationship on the destination class
    */
    private func inverseForeignKey(forRelationshipName relationshipName: OurPropertyName) -> ProviderPropertyName? {
        let relationship = entity.relationshipsByName[relationshipName]
        let relationshipRecordClass = self.dynamicType.classForRelationshipName(relationshipName, context: managedObjectContext!)
        let inverseName = relationship?.inverseRelationship?.name
        
        guard inverseName != nil else {
            return nil
        }
        
        let inverseForeignKey = (relationshipRecordClass.foreignKeyMap() as NSDictionary).allKeysForObject(inverseName!).first()
        
        return inverseForeignKey
    }
    
}
