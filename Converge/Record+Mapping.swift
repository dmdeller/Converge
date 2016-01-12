//
//  Record+Mapping.swift
//  Converge
//
//  Created by David (work) on 1/12/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//

import Foundation
import CoreData

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
    public class func providerIDAttributeName() {
        
    }
    
    /**
     * Relative URL path to fetch JSON data for a collection of records of this class from the provider.
     */
    public class func collectionURLPath(HTTPMethod HTTPMethod: String, parameters: HTTPParameters) -> String {
        
    }
    
    /**
     * Relative URL path to fetch JSON data for a record of this class from the provider.
     */
    public class func URLPath(forID ID: PropertyValue, HTTPMethod: String, parameters: HTTPParameters) -> String {
        
    }
    
    /**
     * Relative URL path to fetch JSON data for a record of this class from the provider.
     */
    public func URLPath(HTTPMethod HTTPMethod: String, parameters: HTTPParameters) -> String {
        
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
    
    internal class func attributeMap(forProviderKeys providerKeys: [ProviderPropertyName], context: NSManagedObjectContext) -> ProviderDataMap {
        
    }
    
    internal class func foreignKeyMap(forProviderKeys providerKeys: [ProviderPropertyName], context: NSManagedObjectContext) -> ProviderDataMap {
        
    }
    
    internal class func relationshipMap(forProviderKeys providerKeys: [ProviderPropertyName], context: NSManagedObjectContext) -> ProviderDataMap {
        
    }
    
    private class func map(forProviderKeys providerKeys: [ProviderPropertyName], configuredMap: ProviderDataMap, automaticNameBlock: (providerKey: AnyObject) -> String, context: NSManagedObjectContext) -> ProviderDataMap {
        
    }
    
    private class func attributeName(forProviderPropertyName providerPropertyName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
    }
    
    private class func inferredAttributeName(forProviderPropertyName providerPropertyName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
    }
    
    private class func relationshipName(forProviderForeignKeyName providerForeignKeyName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
    }
    
    private class func inferredRelationshipName(forProviderForeignKeyName providerForeignKeyName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
    }
    
    private class func relationshipName(forProviderRelationshipName providerRelationshipName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
    }
    
    private class func inferredRelationshipName(forProviderRelationshipName providerRelationshipName: ProviderPropertyName, context: NSManagedObjectContext) -> OurPropertyName? {
        
    }
    
    private class func similarName(forProviderName: ProviderPropertyName, inNames ourNames: [OurPropertyName]) -> OurPropertyName? {
        
    }
    
    private class func providerNameTransformer() -> NSValueTransformer? {
        
    }
    
    private class func ourNameTransformer() -> NSValueTransformer? {
        
    }
    
    private class func inferredProviderForeignKeyName(forRelationship relationship: NSRelationshipDescription) -> ProviderPropertyName? {
        
    }
    
    // MARK: - Querying based on mappings
    
    public class func recordsFromQuery(params: HTTPParameters, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) throws -> [Record] {
        
    }
    
    public class func fetchRequestWithQuery(params: HTTPParameters, sortBy sortDescriptors: [NSSortDescriptor]?, limit: Int, context: NSManagedObjectContext) -> NSFetchRequest? {
        
    }
    
    /**
     * Transforms a set of query parameters into an NSPredicate that can be used for querying.
     */
    internal class func predicateForQuery(params: HTTPParameters, context: NSManagedObjectContext) -> NSPredicate? {
        
    }
    
    // MARK: - Relationship info
    
    /*
    * Given a relationship on this class, returns the name of the provider's foreign key that represents this relationship on the destination class
    */
    private func inverseForeignKey(forRelationshipName relationshipName: OurPropertyName) -> ProviderPropertyName? {
        
    }
    
}
