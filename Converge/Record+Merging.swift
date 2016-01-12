//
//  Record+Merging.swift
//  Converge
//
//  Created by David (work) on 1/12/16.
//  Copyright © 2016 TripCraft LLC. All rights reserved.
//

import Foundation
import CoreData

extension Record {
    
    public typealias AttributeConversionBlock = (PropertyValue?) -> PropertyValue?
    public typealias ProviderRecord = [ObjectIdentifier: AnyObject?]
    
    // MARK: -
    
    /**
    * Subclasses may override to determine whether records should be re-fetched, given the last time they were fetched. If the record(s) have never been fetched, updatedAt will be nil.
    * If not overridden, this method returns NO if updatedAt is less than 30 seconds in DEBUG mode, or 30 minutes in release mode.
    * If this method returns NO, TCKSyncProvider's fetch methods do nothing when asked to fetch, except print a log message and immediately call the success block.
    */
    public class func shouldFetch(lastUpdatedTime updatedAt: NSDate?) -> Bool {
        
    }
    
    /**
    * Subclasses may override this method in order to prevent specific attributes from being output in POST/PATCH, etc. to the provider.
    */
    public class func shouldExportAttribute(attributeName: OurPropertyName) -> Bool {
        return true
    }
    
    // MARK: - Conversions
    
    /**
    * Subclasses may override this method if they want to do some kind of format conversion of attributes coming from the provider prior to inserting into Core Data.
    */
    public class func conversionForAttribute(ourAttributeName: OurPropertyName) -> AttributeConversionBlock? {
        return nil
    }
    
    /**
    * Subclasses should override this method; similar to -conversionForAttribute:, but used when preparing data for export out of Core Data to a provider (via -toDictionary, for instance)
    */
    public class func reverseConversionForAttribute(ourAttributeName: OurPropertyName) -> AttributeConversionBlock? {
        return nil
    }
    
    // MARK: - Built-in Conversions
    
    public class func stringToIntegerConversion() -> AttributeConversionBlock {
        
    }
    
    public class func stringToFloatConversion() -> AttributeConversionBlock {
        
    }
    
    public class func stringToDecimalConversion() -> AttributeConversionBlock {
        
    }
    
    public class func stringToDateConversion() -> AttributeConversionBlock {
        
    }
    
    public class func stringToURLConversion() -> AttributeConversionBlock {
        
    }
    
    public class func URLToStringConversion() -> AttributeConversionBlock {
        
    }
    
    // MARK: - Importing data from provider
    
    /**
    * Given a set of attributes and values from provider data, applies the data to this record.
    */
    public func mergeChangesFromProvider(providerRecord: ProviderRecord, query params: HTTPParameters, recursive: Bool) throws {
        
    }
    
    /**
     * Given a set of attributes and values from provider data, looks for a record with a matching ID and applies the data to that record.
     * If no record yet exists, creates a new record with the data.
     */
    public class func mergeChangesFromProvider(providerRecord: ProviderRecord, query params: HTTPParameters, recursive: Bool, context: NSManagedObjectContext) throws -> Record {
        
    }
    
    /**
    * Given an array of attributes and values from provider data, applies the data to all of the records matched by the predicate.
    *
    * @param shouldDeleteStale Also deletes records matched by the predicate that are not in the provider data. For more discussion on this, see TCKProvider -fetchRecordClass:withQuery:success:onChange:failure:.
    */
    public class func mergeChangesFromProviderCollection(collection: [ProviderRecord], query params: HTTPParameters, recursive: Bool, deleteStale: Bool, context: NSManagedObjectContext, skipInvalidRecords: Bool) throws -> [Record] {
        
    }
    
    // MARK: - Importing - private methods
    
    /*
    * If we supplied some query parameters that do not appear on this record or in the provider data, but do correspond to valid attributes or foreign keys, we can reasonably intuit that they need to be set on this record.
    */
    private func providerRecordWithQueryFields(providerRecord: ProviderRecord, query params: HTTPParameters) -> ProviderRecord {
        
    }
    
    private func mergeAttribute(ourName ourName: OurPropertyName, providerName: ProviderPropertyName, value: PropertyValue) throws {
        
    }
    
    private func mergeForeignKey(ourName ourName: OurPropertyName, providerName: ProviderPropertyName, value: PropertyValue) throws {
        
    }
    
    private func mergeRelatedRecord(ourName ourName: OurPropertyName, providerName: ProviderPropertyName, value: PropertyValue, query params: HTTPParameters) throws {
        
    }
    
    /*
    * Deletes records matched by a predicate not in the provider collection.
    */
    private func deleteRecordsNotInCollection(providerRecordCollection: [ProviderRecord], predicate: NSPredicate, context: NSManagedObjectContext) throws {
        
    }
    
    private func dissociateRecordsNotInCollection(providerRecordCollection: [ProviderRecord], relationship: NSMutableSet) throws {
        
    }
    
    // MARK: - Exporting data to other formats
    
    public class func providerClassName() -> String {
        
    }
    
    /**
     * Returns a dictionary representation of the record, using provider keys.
     */
    public func providerDictionary() -> [ProviderRecord] {
        
    }
    
    /**
     * Returns a JSON representation of the record, using provider keys.
     */
    public func providerJSON() -> NSData {
        
    }
    
    // MARK: -
    
    /*
    * Convenience method to ensure IDs are the correct data type
    */
    internal class func convertedID(ID: PropertyValue) -> String {
        
    }
    
}
