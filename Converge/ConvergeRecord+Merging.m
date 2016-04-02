//
//  ConvergeRecord+Merging.m
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import "ConvergeRecord+Merging.h"

#import <ISO8601DateFormatter/ISO8601DateFormatter.h>
#import <TCKUtilities/TCKUtilities.h>
#import <TCKUtilities/TCKCategories.h>

@implementation ConvergeRecord (Merging)

#ifdef DEBUG
static NSTimeInterval const TCKDefaultCacheTime = 30.0;
#else
static NSTimeInterval const TCKDefaultCacheTime = 30.0 * 60.0;
#endif

#pragma mark -

/**
 * Subclasses may override to determine whether records should be re-fetched, given the last time they were fetched. If the record(s) have never been fetched, updatedAt will be nil.
 * If not overridden, this method returns NO if updatedAt is less than 30 seconds in DEBUG mode, or 30 minutes in release mode.
 * If this method returns NO, TCKSyncProvider's fetch methods do nothing when asked to fetch, except print a log message and immediately call the success block.
 */
+ (BOOL)shouldFetchWithLastUpdatedTime:(NSDate *)updatedAt
{
    if (updatedAt == nil)
    {
        return YES;
    }
    else if ([NSDate.date timeIntervalSinceDate:updatedAt] > TCKDefaultCacheTime)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

/**
 * Subclasses may override this method in order to prevent specific attributes from being output in POST/PATCH, etc. to the provider.
 */
+ (BOOL)shouldExportAttribute:(NSString *)attributeName
{
    return YES;
}

/**
 * Subclasses may override this method if Converge should not attempt to use the record's ID to determine whether the record already exists locally, and always create a new record when it receives one from the server.
 *
 * This method can be used to avoid the requirement that every record from the server must have a unique primary key, in case the server is unable to fulfil this requirement.
 */
+ (BOOL)shouldAlwaysCreateNew
{
    return NO;
}

#pragma mark - Conversions

/**
 * Subclasses may override this method if they want to do some kind of format conversion of attributes coming from the provider prior to inserting into Core Data.
 */
+ (ConvergeAttributeConversionBlock)conversionForAttribute:(NSString *)ourAttributeName
{
    return nil;
}

/**
 * Subclasses should override this method; similar to -conversionForAttribute:, but used when preparing data for export out of Core Data to a provider (via -toDictionary, for instance)
 */
+ (ConvergeAttributeConversionBlock)reverseConversionForAttribute:(NSString *)ourAttributeName
{
    return nil;
}

#pragma mark - Built-In Conversions

+ (ConvergeAttributeConversionBlock)stringToIntegerConversion
{
    return ^NSNumber *(NSString *value)
    {
        if (value == nil || ![value isKindOfClass:NSString.class]) return nil;
        
        NSNumberFormatter *formatter = NSNumberFormatter.new;
        formatter.allowsFloats = NO;
        
        return [formatter numberFromString:value];
    };
}

+ (ConvergeAttributeConversionBlock)stringToFloatConversion
{
    return ^NSNumber *(NSString *value)
    {
        if (value == nil || ![value isKindOfClass:NSString.class]) return nil;
        
        NSNumberFormatter *formatter = NSNumberFormatter.new;
        formatter.allowsFloats = YES;
        
        return [formatter numberFromString:value];
    };
}

+ (ConvergeAttributeConversionBlock)stringToDecimalConversion
{
    return ^NSNumber *(NSString *value)
    {
        if (value == nil || ![value isKindOfClass:NSString.class]) return nil;
        
        return [NSDecimalNumber decimalNumberWithString:value];
    };
}

+ (ConvergeAttributeConversionBlock)stringToDateConversion
{
    return ^NSDate *(NSString *value)
    {
        if (value == nil || ![value isKindOfClass:NSString.class]) return nil;
        
        ISO8601DateFormatter *formatter = ISO8601DateFormatter.new;
        
        return [formatter dateFromString:value];
    };
}

+ (ConvergeAttributeConversionBlock)stringToURLConversion
{
    return ^NSURL *(NSString *URLString)
    {
        return [NSURL URLWithString:URLString];
    };
}

+ (ConvergeAttributeConversionBlock)URLToStringConversion
{
    return ^NSString *(NSURL *URL)
    {
        return URL.absoluteString;
    };
}

#pragma mark - Importing data from provider

/**
 * Given a set of attributes and values from provider data, applies the data to this record.
 */
- (BOOL)mergeChangesFromProvider:(NSDictionary *)providerRecord withQuery:(NSDictionary *)query recursive:(BOOL)recursive error:(NSError **)errorRef
{
    [self.managedObjectContext.undoManager beginUndoGrouping];
    
    NSMutableArray *keys = providerRecord.allKeys.mutableCopy;
    [keys addObjectsFromArray:query.allKeys];
    
    NSDictionary *attributeMap = [self.class attributeMapForProviderKeys:keys context:self.managedObjectContext];
    NSDictionary *foreignKeyMap = [self.class foreignKeyMapForProviderKeys:keys context:self.managedObjectContext];
    NSDictionary *relationshipMap = [self.class relationshipMapForProviderKeys:keys context:self.managedObjectContext];
    
    // Sort our keys alphabetically to ensure deterministic behavior
    NSMutableArray *ourAttributes = [attributeMap.allKeys sortedArrayUsingSelector:@selector(compare:)].mutableCopy;
    NSArray *ourForeignKeys = [foreignKeyMap.allKeys sortedArrayUsingSelector:@selector(compare:)];
    NSArray *ourRelationships = [relationshipMap.allKeys sortedArrayUsingSelector:@selector(compare:)];
    
    providerRecord = [self providerRecord:providerRecord withMissingFieldsFromQuery:query];
    
    NSUInteger idIndex = [ourAttributes indexOfObject:self.class.IDAttributeName];
    if (idIndex != NSNotFound)
    {
        // Make 'id' key first in keys array, so that it is evaluated first
        id idData = [ourAttributes objectAtIndex:idIndex];
        [ourAttributes removeObjectAtIndex:idIndex];
        [ourAttributes insertObject:idData atIndex:0];
    }
    
    for (NSString *ourKey in ourAttributes)
    {
        id providerKey = attributeMap[ourKey];
        id providerData = TCKNullToNil([providerRecord objectAtPath_tc:providerKey]);
        
        if (providerData != nil)
        {
            NSError *error = nil;
            if (![self mergeAttributeForKey:ourKey fromProviderKey:providerKey withData:providerData error:&error])
            {
                NSLog(@"%@: Error merging attribute, skipping: %@", self.class, error.userInfo[ConvergeMergeableRecordUserInfoLogMessage]);
            }
        }
    }
    
    for (NSString *ourKey in ourForeignKeys)
    {
        id providerKey = foreignKeyMap[ourKey];
        id providerData = TCKNullToNil([providerRecord objectAtPath_tc:providerKey]);
        
        if (providerData != nil)
        {
            NSError *error = nil;
            if (![self mergeForeignKey:ourKey fromProviderKey:providerKey withData:providerData error:&error])
            {
                NSLog(@"%@: Error merging foreign key, skipping: %@", self.class, error.userInfo[ConvergeMergeableRecordUserInfoLogMessage]);
            }
        }
    }
    
    if (recursive)
    {
        for (NSString *ourKey in ourRelationships)
        {
            id providerKey = relationshipMap[ourKey];
            id providerData = TCKNullToNil([providerRecord objectAtPath_tc:providerKey]);
            
            if (providerData != nil)
            {
                NSError *error = nil;
                if (![self mergeRelatedRecordForKey:ourKey fromProviderKey:providerKey withData:providerData andQuery:query error:&error])
                {
                    NSLog(@"%@: Error merging related record, skipping: %@", self.class, error.userInfo[ConvergeMergeableRecordUserInfoLogMessage]);
                }
            }
        }
    }
    
    [self.managedObjectContext.undoManager endUndoGrouping];
    
    NSError *insertValidationError = nil;
    NSError *updateValidationError = nil;
    if ([self validateForInsert:&insertValidationError] && [self validateForUpdate:&updateValidationError])
    {
        return YES;
    }
    else
    {
        NSError *validationError = nil;
        ConvergeMergeableRecordValidationType validationType = ConvergeMergeableRecordValidationTypeUnknown;
        if (insertValidationError != nil)
        {
            validationError = insertValidationError;
            validationType = ConvergeMergeableRecordValidationTypeInsert;
        }
        else if (updateValidationError != nil)
        {
            validationError = updateValidationError;
            validationType = ConvergeMergeableRecordValidationTypeUpdate;
        }
        
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"The record could not be updated",
            NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
            ConvergeMergeableRecordUserInfoRecord: self,
            ConvergeMergeableRecordUserInfoProviderData: TCKNilToNull(providerRecord),
            ConvergeMergeableRecordUserInfoOriginalError: TCKNilToNull(validationError),
            ConvergeMergeableRecordUserInfoValidationType: @(validationType),
            ConvergeMergeableRecordUserInfoChangedValues: TCKNilToNull(self.changedValues),
        };
        NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorFailedValidation userInfo:userInfo];
        if (errorRef != nil) *errorRef = error;
        
        [self.managedObjectContext.undoManager undoNestedGroup];
        
        return NO;
    }
}

/**
 * Given a set of attributes and values from provider data, looks for a record with a matching ID and applies the data to that record.
 * If no record yet exists, creates a new record with the data.
 */
+ (instancetype)mergeChangesFromProvider:(NSDictionary *)providerRecord withQuery:(NSDictionary *)query recursive:(BOOL)recursive context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    ConvergeRecord *ourRecord = nil;
    BOOL isNew = NO;
    
    if ([self shouldAlwaysCreateNew])
    {
        isNew = YES;
    }
    else
    {
        id idAttribute = [self providerIDAttributeName];
        
        id theID = [providerRecord objectAtPath_tc:idAttribute];
        if (theID == nil)
        {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"The record could not be updated",
                NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
                ConvergeMergeableRecordUserInfoProviderData: TCKNilToNull(providerRecord),
            };
            NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorProviderIDMissing userInfo:userInfo];
            if (errorRef != nil) *errorRef = error;
            
            return nil;
        }
        
        theID = [self convertedID:theID];
        if (![self value:theID isCorrectClassForAttributeName:self.IDAttributeName inContext:context])
        {
            Class correctClass = [self classForAttributeName:self.IDAttributeName inContext:context];
            
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"The record could not be updated",
                NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
                ConvergeMergeableRecordUserInfoProviderData: TCKNilToNull(providerRecord),
                ConvergeMergeableRecordUserInfoExpected: TCKNilToNull(NSStringFromClass(correctClass)),
                ConvergeMergeableRecordUserInfoActual: TCKNilToNull(theID),
            };
            NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorProviderIDWrongType userInfo:userInfo];
            if (errorRef != nil) *errorRef = error;
            
            return nil;
        }
        
        NSError *error = nil;
        ourRecord = (ConvergeRecord *)[self recordForID:theID context:context error:&error];
        
        if (ourRecord == nil)
        {
            if (error == nil)
            {
                isNew = YES;
            }
            else
            {
                if (errorRef != nil) *errorRef = error;
                return nil;
            }
        }
    }
    
    if (isNew)
    {
        ourRecord = (ConvergeRecord *)[self newRecordInContext:context];
    }
    
    NSError *error = nil;
    if ([ourRecord mergeChangesFromProvider:providerRecord withQuery:query recursive:recursive error:&error])
    {
        return ourRecord;
    }
    else
    {
        if (isNew)
        {
            [context deleteObject:ourRecord];
        }
        
        if (errorRef != nil) *errorRef = error;
        return nil;
    }
}

/**
 * Given an array of attributes and values from provider data, applies the data to all of the records matched by the predicate.
 *
 * @param shouldDeleteStale Also deletes records matched by the predicate that are not in the provider data. For more discussion on this, see TCKProvider -fetchRecordClass:withQuery:success:onChange:failure:.
 */
+ (NSArray *)mergeChangesFromProviderCollection:(NSArray *)collection withQuery:(NSDictionary *)query recursive:(BOOL)recursive deleteStale:(BOOL)shouldDeleteStale context:(NSManagedObjectContext *)context skipInvalidRecords:(BOOL)skipInvalid error:(NSError **)errorRef
{
    NSMutableArray *ourRecords = [NSMutableArray arrayWithCapacity:collection.count];
    
    for (NSDictionary *providerRecord in collection)
    {
        NSError *error = nil;
        ConvergeRecord *ourRecord = [self mergeChangesFromProvider:providerRecord withQuery:query recursive:recursive context:context error:&error];
        if (ourRecord != nil)
        {
            [ourRecords addObject:ourRecord];
        }
        else
        {
            if (skipInvalid)
            {
                if ([error.domain isEqualToString:ConvergeRecordErrorDomain] && error.code == ConvergeMergeableRecordErrorProviderIDMissing)
                {
                    NSLog(@"%@: Skipping record because ID attribute (%@) was not found: %@", self, self.IDAttributeName, providerRecord);
                }
                else if ([error.domain isEqualToString:ConvergeRecordErrorDomain] && error.code == ConvergeMergeableRecordErrorProviderIDWrongType)
                {
                    NSString *correctClassName = TCKNullToNil(error.userInfo[ConvergeMergeableRecordUserInfoExpected]);
                    id theID = TCKNullToNil(error.userInfo[ConvergeMergeableRecordUserInfoActual]);
                    
                    NSLog(@"%@: Skipping record because ID attribute (%@) is wrong class; expected %@, found %@ (%@)", self.class, self.IDAttributeName, correctClassName, [theID class], theID);
                }
                else if ([error.domain isEqualToString:ConvergeRecordErrorDomain] && error.code == ConvergeMergeableRecordErrorFailedValidation)
                {
                    NSDictionary *changedValues = TCKNullToNil(error.userInfo[ConvergeMergeableRecordUserInfoChangedValues]);
                    
                    NSLog(@"%@: Skipping record because changes failed validation, will not be updated: %@, error: %@", self.class, changedValues, error.userInfo);
                }
                else
                {
                    if (errorRef != nil) *errorRef = error;
                    return nil;
                }
                
                continue;
            }
            else
            {
                if (errorRef != nil) *errorRef = error;
                return nil;
            }
        }
    }
    
    if (shouldDeleteStale)
    {
        NSPredicate *predicate = [self predicateForQuery:query context:context];
        NSError *error = nil;
        if (![self deleteRecordsNotInCollection:collection withPredicate:predicate context:context error:&error])
        {
            if (error != nil && errorRef != nil) *errorRef = error;
            return nil;
        }
    }
    
    return ourRecords;
}

#pragma mark - Importing - private methods

/*
 * If we supplied some query parameters that do not appear on this record or in the provider data, but do correspond to valid attributes or foreign keys, we can reasonably intuit that they need to be set on this record.
 */
- (NSDictionary *)providerRecord:(NSDictionary *)providerRecord withMissingFieldsFromQuery:(NSDictionary *)query
{
    if (query == nil)
    {
        return providerRecord;
    }
    
    NSMutableArray *keys = providerRecord.allKeys.mutableCopy;
    [keys addObjectsFromArray:query.allKeys];
    
    NSMutableDictionary *attributeAndForeignKeyMap = [NSMutableDictionary dictionaryWithDictionary:[self.class attributeMapForProviderKeys:keys context:self.managedObjectContext]];
    [attributeAndForeignKeyMap addEntriesFromDictionary:[self.class foreignKeyMapForProviderKeys:keys context:self.managedObjectContext]];
    
    NSMutableDictionary *combinedRecord = providerRecord.mutableCopy;
    
    for (NSString *ourKey in attributeAndForeignKeyMap)
    {
        id providerKey = attributeAndForeignKeyMap[ourKey];
        
        if ([providerKey isKindOfClass:NSString.class] && query[providerKey] != nil && providerRecord[providerKey] == nil)
        {
            combinedRecord[providerKey] = query[providerKey];
        }
    }
    
    return combinedRecord;
}

- (BOOL)mergeAttributeForKey:(NSString *)ourAttributeKey fromProviderKey:(id)providerKey withData:(id)providerData error:(NSError **)errorRef
{
    ConvergeAttributeConversionBlock convert = [self.class conversionForAttribute:ourAttributeKey];
    
    if (convert != nil)
    {
        providerData = convert(providerData);
    }
    else if ([providerKey isEqual:self.class.providerIDAttributeName])
    {
        providerData = [self.class convertedID:providerData];
    }
    
    providerData = TCKNullToNil(providerData);
    
    if ([self.class value:providerData isCorrectClassForAttributeName:ourAttributeKey inContext:self.managedObjectContext])
    {
        [self setValue:providerData forKey:ourAttributeKey];
        
        return YES;
    }
    else
    {
        Class correctClass = [self.class classForAttributeName:ourAttributeKey inContext:self.managedObjectContext];
        
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"The attribute could not be updated",
            NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
            ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"Incorrect class for attribute: %@, expected class: %@, given class: %@, data: %@", ourAttributeKey, correctClass, [providerData class], providerData],
        };
        NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorProviderAttributeWrongType userInfo:userInfo];
        if (errorRef != nil) *errorRef = error;
        
        return NO;
    }
}

- (BOOL)mergeForeignKey:(NSString *)ourForeignKey fromProviderKey:(id)providerKey withData:(id)providerData error:(NSError **)errorRef
{
    if (providerData == nil || [providerData isKindOfClass:[NSNull class]])
    {
        NSLog(@"ConvergeMergeableRecord: %@ relationship on %@ is being set to null, as per provider's data - this might indicate an error in the provider's data", ourForeignKey, NSStringFromClass([self class]));
        [self setValue:nil forKey:ourForeignKey];
        
        return YES;
    }
    
    Class relationshipRecordClass = [[self class] classForRelationshipName:ourForeignKey context:[self managedObjectContext]];
    
    // Determine whether class responds to the methods we need
    if (![relationshipRecordClass respondsToSelector:@selector(recordForID:context:error:)])
    {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"The related record could not be updated",
            NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
            ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"Destination class of %@ relationship on %@ is %@, which does not respond to recordForID:context:error:", ourForeignKey, NSStringFromClass([self class]), NSStringFromClass(relationshipRecordClass)],
        };
        NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorExpectedConvergeRecord userInfo:userInfo];
        if (errorRef != nil) *errorRef = error;
        
        return NO;
    }
    
    NSRelationshipDescription *relationshipDesc = [self.entity.relationshipsByName objectForKey:ourForeignKey];
    if (relationshipDesc.isToMany)
    {
        NSArray *foreignIDs = TCKEnsureArray(providerData);
        
        id relationshipSet = nil;
        if (relationshipDesc.isOrdered)
        {
            relationshipSet = [self mutableOrderedSetValueForKey:ourForeignKey];
        }
        else
        {
            relationshipSet = [self mutableSetValueForKey:ourForeignKey];
        }
        
        if (relationshipSet == nil)
        {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"The related record could not be updated",
                NSLocalizedFailureReasonErrorKey: @"The database could not accept this data.",
                ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"Provider has %@ as a to-many relationship on %@, but our core data store is not configured this way", ourForeignKey, NSStringFromClass([self class])],
            };
            NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorProviderToManyLocalToOne userInfo:userInfo];
            if (errorRef != nil) *errorRef = error;
            
            return NO;
        }
        
        NSUInteger numUpdates = 0;
        
        for (id maybeForeignID in foreignIDs)
        {
            id foreignID = [relationshipRecordClass convertedID:maybeForeignID];
            
            if (![relationshipRecordClass value:foreignID isCorrectClassForAttributeName:relationshipRecordClass.IDAttributeName inContext:self.managedObjectContext])
            {
                Class correctClass = [relationshipRecordClass classForAttributeName:relationshipRecordClass.IDAttributeName inContext:self.managedObjectContext];
                NSLog(@"%@: Skipping foreign record because ID attribute (%@) is wrong class; expected %@, found %@ (%@)", self.class, relationshipRecordClass.IDAttributeName, correctClass, [foreignID class], foreignID);
                continue;
            }
            
            NSError *error = nil;
            ConvergeRecord *relatedRecord = (ConvergeRecord *)[relationshipRecordClass recordForID:foreignID context:[self managedObjectContext] error:&error];
            
            if (relatedRecord != nil)
            {
                [relationshipSet addObject:relatedRecord];
                
                numUpdates += 1;
            }
            else
            {
                NSLog(@"ConvergeMergeableRecord: unable to update %@ relationship for %@ because the core data %@ with id %@ was not found:", ourForeignKey, NSStringFromClass([self class]), NSStringFromClass(relationshipRecordClass), foreignID);
                
                if (error != nil)
                {
                    NSLog(@"ConvergeMergeableRecord: core data error: %@", [error userInfo]);
                }
                
                continue;
            }
        }
        
        if (numUpdates > 0 || foreignIDs.count == 0)
        {
            return YES;
        }
        else
        {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"The related records could not be updated",
                NSLocalizedFailureReasonErrorKey: @"None of the provided records could be used.",
                ConvergeMergeableRecordUserInfoLogMessage: @"None of the provided keys could be merged successfully. See previous console log messages for details.",
            };
            NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorMultipleErrors userInfo:userInfo];
            if (errorRef != nil) *errorRef = error;
            
            return NO;
        }
    }
    else
    {
        id foreignID = [relationshipRecordClass convertedID:providerData];
        
        if (![relationshipRecordClass value:foreignID isCorrectClassForAttributeName:relationshipRecordClass.IDAttributeName inContext:self.managedObjectContext])
        {
            Class correctClass = [relationshipRecordClass classForAttributeName:relationshipRecordClass.IDAttributeName inContext:self.managedObjectContext];
            
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"The related record could not be updated",
                NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
                ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"ID attribute (%@) is wrong class; expected %@, found %@ (%@)", relationshipRecordClass.IDAttributeName, correctClass, [foreignID class], foreignID],
            };
            NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorProviderIDWrongType userInfo:userInfo];
            if (errorRef != nil) *errorRef = error;
            
            return NO;
        }
        
        NSError *error = nil;
        ConvergeRecord *relatedRecord = (ConvergeRecord *)[relationshipRecordClass recordForID:foreignID context:[self managedObjectContext] error:&error];
        
        if (relatedRecord != nil)
        {
            [self setValue:relatedRecord forKey:ourForeignKey];
            
            return YES;
        }
        else
        {
            if (error == nil)
            {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"The related record could not be updated",
                    NSLocalizedFailureReasonErrorKey: @"The referenced record is not in the database.",
                    ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"Unable to update %@ relationship for %@ because the core data %@ with id %@ was not found:", ourForeignKey, NSStringFromClass([self class]), NSStringFromClass(relationshipRecordClass), foreignID],
                };
                error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorLocalRecordNotFound userInfo:userInfo];
                if (errorRef != nil) *errorRef = error;
            }
            else
            {
                if (errorRef != nil) *errorRef = error;
            }
            
            return NO;
        }
    }
}

- (BOOL)mergeRelatedRecordForKey:(NSString *)ourRelationshipName fromProviderKey:(id)providerKey withData:(id)providerData andQuery:(NSDictionary *)origQuery error:(NSError **)errorRef
{
    NSMutableDictionary *query = origQuery.mutableCopy;
    if (query == nil) query = NSMutableDictionary.new;
    
    NSRelationshipDescription *ourRelationship = self.entity.relationshipsByName[ourRelationshipName];
    Class relationshipRecordClass = [self.class classForRelationshipName:ourRelationshipName context:self.managedObjectContext];

    NSString *inverseForeignKey = relationshipRecordClass.foreignKeyMap[ourRelationship.inverseRelationship.name];
    if (inverseForeignKey == nil)
    {
        inverseForeignKey = [self.class inferredProviderForeignKeyNameForRelationship:ourRelationship.inverseRelationship];
    }
    
    [query setObject:self.configuredID forKey:inverseForeignKey];
    
    if ([providerData isKindOfClass:[NSArray class]])
    {
        //NSLog(@"ConvergeMergeableRecord: recursively merging %@ collection related to %@", NSStringFromClass(relationshipRecordClass), NSStringFromClass([self class]));
        
        BOOL isManyToMany = NO;
        if (ourRelationship.inverseRelationship.isToMany)
        {
            isManyToMany = YES;
        }
        else
        {
            isManyToMany = NO;
        }
        
        // For One-To-Many relationships, we should delete related records that no longer appear in provider's data.
        // For Many-To-Many, we shouldn't delete those records, only dissociate them (see below).
        BOOL shouldDeleteStale = !isManyToMany;
        NSError *error = nil;
        NSArray *mergedRecords = [relationshipRecordClass mergeChangesFromProviderCollection:providerData withQuery:query recursive:YES deleteStale:shouldDeleteStale context:self.managedObjectContext skipInvalidRecords:YES error:&error];
        if (mergedRecords == nil)
        {
            if (error != nil && errorRef != nil) *errorRef = error;
            return NO;
        }
        
        if (isManyToMany)
        {
            id ourRelationshipRecords = nil;
            if (ourRelationship.inverseRelationship.isOrdered)
            {
                ourRelationshipRecords = [self mutableOrderedSetValueForKey:ourRelationshipName];
            }
            else
            {
                ourRelationshipRecords = [self mutableSetValueForKey:ourRelationshipName];
            }
            
            for (ConvergeRecord *mergedRecord in mergedRecords)
            {
                [ourRelationshipRecords addObject:mergedRecord];
            }
            
            if ([relationshipRecordClass hasConfiguredIDInContext:self.managedObjectContext])
            {
                error = nil;
                if (![self dissociateRecordsNotInCollection:providerData forRelationship:ourRelationshipRecords error:&error])
                {
                    if (error != nil && errorRef != nil) *errorRef = error;
                    return NO;
                }
            }
        }
        
        if (mergedRecords.count > 0 || [providerData count] == 0)
        {
            return YES;
        }
        else
        {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"The related records could not be updated",
                NSLocalizedFailureReasonErrorKey: @"None of the provided records could be used.",
                ConvergeMergeableRecordUserInfoLogMessage: @"None of the provider records could be merged successfully. See previous console log messages for details.",
            };
            NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorMultipleErrors userInfo:userInfo];
            if (errorRef != nil) *errorRef = error;
            
            return NO;
        }
    }
    else if ([providerData isKindOfClass:[NSDictionary class]])
    {
        //NSLog(@"ConvergeMergeableRecord: recursively merging %@ related to %@", NSStringFromClass(relationshipRecordClass), NSStringFromClass([self class]));
        
        NSDictionary *providerRelatedRecord = (NSDictionary *)providerData;
        
        ConvergeRecord *relatedRecord = nil;
        BOOL isNew = NO;
        
        if ([relationshipRecordClass shouldAlwaysCreateNew])
        {
            isNew = YES;
        }
        else
        {
            id foreignIdName = [relationshipRecordClass providerIDAttributeName];
            
            id foreignID = [providerRelatedRecord objectAtPath_tc:foreignIdName];
            
            if (foreignID == nil)
            {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"The related record could not be updated",
                    NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
                    ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"Related record %@ on %@ has no ID and cannot be used", providerKey, NSStringFromClass([self class])],
                    ConvergeMergeableRecordUserInfoProviderData: TCKNilToNull(providerRelatedRecord),
                };
                NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorProviderIDMissing userInfo:userInfo];
                if (errorRef != nil) *errorRef = error;
                
                return NO;
            }
            
            foreignID = [relationshipRecordClass convertedID:foreignID];
            if (![relationshipRecordClass value:foreignID isCorrectClassForAttributeName:relationshipRecordClass.IDAttributeName inContext:self.managedObjectContext])
            {
                Class correctClass = [relationshipRecordClass classForAttributeName:relationshipRecordClass.IDAttributeName inContext:self.managedObjectContext];
                
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"The related record could not be updated",
                    NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
                    ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"ID attribute (%@) is wrong class; expected %@, found %@ (%@)", relationshipRecordClass.IDAttributeName, correctClass, [foreignID class], foreignID],
                    ConvergeMergeableRecordUserInfoProviderData: TCKNilToNull(providerRelatedRecord),
                };
                NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorProviderIDWrongType userInfo:userInfo];
                if (errorRef != nil) *errorRef = error;
                
                return NO;
            }
            
            // Determine whether class responds to the methods we need
            if (![relationshipRecordClass respondsToSelector:@selector(recordForID:context:error:)])
            {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"The related record could not be updated",
                    NSLocalizedFailureReasonErrorKey: @"The database could not accept this data.",
                    ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"Destination class of %@ relationship on %@ is %@, which does not respond to recordForID:context:error:", ourRelationshipName, NSStringFromClass([self class]), NSStringFromClass(relationshipRecordClass)],
                    ConvergeMergeableRecordUserInfoProviderData: TCKNilToNull(providerRelatedRecord),
                };
                NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorExpectedConvergeRecord userInfo:userInfo];
                if (errorRef != nil) *errorRef = error;
                
                return NO;
            }
            
            NSError *error = nil;
            ConvergeRecord *relatedRecord = (ConvergeRecord *)[relationshipRecordClass recordForID:foreignID context:self.managedObjectContext error:&error];
            
            if (relatedRecord == nil)
            {
                isNew = YES;
            }
        }
        
        if (isNew)
        {
            relatedRecord = (ConvergeRecord *)[relationshipRecordClass newRecordInContext:self.managedObjectContext];
        }
        
        NSError *error = nil;
        if ([relatedRecord mergeChangesFromProvider:providerRelatedRecord withQuery:query recursive:YES error:&error])
        {
            [self setValue:relatedRecord forKey:ourRelationshipName];
            
            return YES;
        }
        else
        {
            if (isNew)
            {
                [self.managedObjectContext deleteObject:relatedRecord];
            }
            
            if (error != nil && errorRef != nil) *errorRef = error;
            
            return NO;
        }
    }
    else
    {
        NSDictionary *userInfo = @{
            NSLocalizedDescriptionKey: @"The related record could not be updated",
            NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
            ConvergeMergeableRecordUserInfoLogMessage: [NSString stringWithFormat:@"Unknown type of data specified by provider in class: %@ for provider's key: %@ - expected array or dictionary", NSStringFromClass([self class]), providerKey],
            ConvergeMergeableRecordUserInfoProviderData: TCKNilToNull(providerData),
        };
        NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeMergeableRecordErrorExpectedCollection userInfo:userInfo];
        if (errorRef != nil) *errorRef = error;
        
        return NO;
    }
}

/*
 * Deletes records matched by a predicate not in the provider collection.
 *
 * Not intended to be called externally.
 */
+ (BOOL)deleteRecordsNotInCollection:(NSArray *)providerRecordCollection withPredicate:(NSPredicate *)predicate context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:providerRecordCollection.count];
    
    for (NSDictionary *providerRecord in providerRecordCollection)
    {
        id theID = [self convertedID:[providerRecord objectAtPath_tc:self.providerIDAttributeName]];
        
        if (theID != nil)
        {
            [ids addObject:theID];
        }
    }
    
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    fetch.entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
    
    NSPredicate *excludeProviderIDsPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(NOT (%@ IN %%@)) OR %@ = %%@", self.IDAttributeName, self.IDAttributeName], ids, [NSNull null]];
    
    if (predicate != nil)
    {
        fetch.predicate = [NSCompoundPredicate andPredicateWithSubpredicates:[NSArray arrayWithObjects:predicate, excludeProviderIDsPredicate, nil]];
    }
    else
    {
        fetch.predicate = excludeProviderIDsPredicate;
    }
    
    NSError *error = nil;
    NSArray *ourRecordsForDeletion = [context executeFetchRequest:fetch error:&error];
    
    for (ConvergeRecord *ourRecord in ourRecordsForDeletion)
    {
        NSLog(@"ConvergeMergeableRecord: deleting %@ id %@ because it no longer exists in provider data", NSStringFromClass([self class]), ourRecord.configuredID);
        [context deleteObject:ourRecord];
    }
    
    return YES;
}

- (BOOL)dissociateRecordsNotInCollection:(NSArray *)providerRecordCollection forRelationship:(NSMutableSet *)relationship error:(NSError **)errorRef
{
    NSMutableArray *ids = [NSMutableArray arrayWithCapacity:providerRecordCollection.count];
    
    for (NSDictionary *providerRecord in providerRecordCollection)
    {
        id theID = [self.class convertedID:[providerRecord objectAtPath_tc:self.class.providerIDAttributeName]];
        if (theID != nil)
        {
            [ids addObject:theID];
        }
    }
    
    for (ConvergeRecord *foreignRecord in relationship.allObjects)
    {
        if (![ids containsObject:foreignRecord.configuredID])
        {
            NSLog(@"ConvergeMergeableRecord: dissociating %@ id %@ from %@ id %@ because it no longer exists in provider data", NSStringFromClass(foreignRecord.class), foreignRecord.configuredID, NSStringFromClass(self.class), self.configuredID);
            [relationship removeObject:foreignRecord];
        }
    }
    
    return YES;
}

#pragma mark - Exporting data to other formats

+ (NSString *)providerClassName
{
    return [self.providerNameTransformer transformedValue:[self.ourNameTransformer reverseTransformedValue:self.entityName]];
}

/**
 * Returns a dictionary representation of the record, using provider keys.
 */
- (NSDictionary *)providerDictionary
{
    NSMutableDictionary *asDictionary = [NSMutableDictionary dictionaryWithCapacity:10];
    
    NSDictionary *attributeMap = self.class.attributeMap;
    NSDictionary *foreignKeyMap = self.class.foreignKeyMap;
    
    for (NSString *ourKey in self.entity.attributesByName.allKeys)
    {
        if (![self.class shouldExportAttribute:ourKey])
        {
            continue;
        }
        
        id providerKey = attributeMap[ourKey];
        if (providerKey == nil)
        {
            providerKey = [self.class.providerNameTransformer transformedValue:[self.class.ourNameTransformer reverseTransformedValue:ourKey]];
        }
        
        id value = [self valueForKey:ourKey];
        
        if (value != nil)
        {
            ConvergeAttributeConversionBlock convert = [self.class reverseConversionForAttribute:ourKey];
            
            if (convert != nil)
            {
                value = convert(value);
            }
            else if ([value isKindOfClass:[NSDate class]])
            {
                ISO8601DateFormatter *formatter = ISO8601DateFormatter.new;
                formatter.includeTime = YES;
                
                value = [formatter stringFromDate:value];
            }
            else if ([value isKindOfClass:NSNumber.class])
            {
                NSAttributeDescription *attributeDesc = [self.entity.attributesByName objectForKey:ourKey];
                if (attributeDesc.attributeType == NSBooleanAttributeType)
                {
                    NSNumber *numberValue = (NSNumber *)value;
                    
                    // This seems silly and redundant, but it's actually forcing NSJSONSerialization to output a literal boolean instead of an integer.
                    // -numberWithBool: has some kind of special power that remembers it's supposed to be a boolean, whereas the NSNumber we pull out of Core Data does not (even though the attribute is specified as boolean).
                    value = [NSNumber numberWithBool:numberValue.boolValue];
                }
            }
            // This test is ridiculous; +isValidJSONObject: can only accept an NSDictionary, apparently: http://stackoverflow.com/a/13405219
            else if (![NSJSONSerialization isValidJSONObject:@{@"test": TCKNilToNull(value)}])
            {
                NSLog(@"%@: Skipping %@ in JSON output because %@ can't be encoded in JSON: %@", self.class, ourKey, [value class], value);
                continue;
            }
            
            asDictionary[providerKey] = value;
        }
    }
    
    for (NSString *ourKey in self.entity.relationshipsByName.allKeys)
    {
        NSRelationshipDescription *relationship = self.entity.relationshipsByName[ourKey];
        
        id providerKey = foreignKeyMap[ourKey];
        if (providerKey == nil)
        {
            providerKey = [self.class inferredProviderForeignKeyNameForRelationship:relationship];
        }
        
        id value = [self valueForKey:ourKey];
        if (relationship.isToMany)
        {
            if (value != nil && [value isKindOfClass:NSSet.class])
            {
                NSSet *set = value;
                NSMutableArray *IDs = [NSMutableArray arrayWithCapacity:set.count];
                
                for (ConvergeRecord *record in set)
                {
                    if (record.hasConfiguredID)
                    {
                        [IDs addObject:TCKNilToNull(record.configuredID)];
                    }
                }
                
                asDictionary[providerKey] = IDs.immutableCopy_tc;
            }
        }
        else
        {
            if (value != nil && [value isKindOfClass:[ConvergeRecord class]])
            {
                ConvergeRecord *foreignRecord = (ConvergeRecord *)value;
                
                if (foreignRecord.hasConfiguredID)
                {
                    asDictionary[providerKey] = TCKNilToNull(foreignRecord.configuredID);
                }
            }
        }
    }
    
    return asDictionary;
}

/**
 * Returns a JSON representation of the record, using provider keys.
 */
- (NSData *)providerJSON
{
    NSError *error = nil;
    NSData *json = [NSJSONSerialization dataWithJSONObject:[self providerDictionary] options:0 error:&error];
    
    if (json != nil)
    {
        return json;
    }
    else
    {
        NSLog(@"%@: error converting to JSON: %@", self.class, [error userInfo]);
        return nil;
    }
}

#pragma mark -

/*
 * Convenience method to ensure IDs are the correct data type
 */
+ (NSString *)convertedID:(id)theID
{
    ConvergeAttributeConversionBlock convert = [self conversionForAttribute:self.IDAttributeName];
    
    if (convert != nil)
    {
        return convert(theID);
    }
    else
    {
        return theID;
    }
}


@end
