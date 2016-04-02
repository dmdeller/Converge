//
//  ConvergeRecord.m
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import "ConvergeRecord.h"

#import <TCKUtilities/TCKUtilities.h>
#import <TCKUtilities/TCKMacros.h>

@implementation ConvergeRecord

#pragma mark - Configuration

/**
 * Override if this class's ID has a different name
 */
+ (NSString *)IDAttributeName
{
    return @"id";
}

#pragma mark -

// Note: If you use mogenerator, it automatically overrides this method to do the right thing!
+ (NSString*)entityName
{
	return NSStringFromClass(self.class);
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_
{
	return [NSEntityDescription entityForName:self.entityName inManagedObjectContext:moc_];
}

#pragma mark - ID

- (NSString *)configuredID
{
    if (self.class.IDAttributeName == nil)
    {
        TCKRaiseFormat(@"No IDAttributeName configured for class: %@ -- HINT: If this class isn't supposed to or can't have an ID, return YES from +shouldAlwaysCreateNew. You will lose some merging functionality by doing this.", self.class);
    }
    
    return [self valueForKey:self.class.IDAttributeName];
}

- (void)setConfiguredID:(NSString *)newConfiguredID
{
    if (self.class.IDAttributeName == nil)
    {
        TCKRaiseFormat(@"No IDAttributeName configured for class: %@", self.class);
    }
    
    [self setValue:newConfiguredID forKey:self.class.IDAttributeName];
}

- (BOOL)hasConfiguredID
{
    return [self.class hasConfiguredIDInContext:self.managedObjectContext];
}

+ (BOOL)hasConfiguredIDInContext:(NSManagedObjectContext *)context
{
    if (self.IDAttributeName == nil)
    {
        return NO;
    }
    else if ([[self entityInManagedObjectContext:context].propertiesByName.allKeys containsObject:self.IDAttributeName])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Querying

/**
 * Given an ID, returns the record with that ID.
 */
+ (instancetype)recordForID:(id)theID context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    if (theID == nil)
    {
        return nil;
    }
    else if (![self hasConfiguredIDInContext:context])
    {
        TCKRaiseFormat(@"%@: Does not have a configured ID", self.class);
    }
    else if (![self value:theID isCorrectClassForAttributeName:self.IDAttributeName inContext:context])
    {
        Class correctClass = [self classForAttributeName:self.IDAttributeName inContext:context];
        TCKRaiseFormat(@"%@: Wrong class for ID attribute; expected %@, got %@ (%@)", self.class, correctClass, [theID class], theID);
    }
    
    NSError *error = nil;
    ConvergeRecord *record = [self recordWhere:[NSDictionary dictionaryWithObject:theID forKey:self.IDAttributeName] requireAll:YES sortBy:nil context:context error:&error];
    
    if (record == nil)
    {
        if (error != nil && errorRef != nil) *errorRef = error;
        return nil;
    }
    else
    {
        return record;
    }
}

+ (NSArray *)allRecordsSortedBy:(NSArray *)sortDescriptors context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSError *error = nil;
    NSArray *records = [self recordsWhere:@{} requireAll:YES sortBy:sortDescriptors limit:0 context:context error:&error];
    
    if (records == nil)
    {
        if (error != nil && errorRef != nil) *errorRef = error;
        return nil;
    }
    else
    {
        return records;
    }
}

/**
 * Given an attribute name and value, returns any records that match.
 */
+ (NSArray *)recordsWhere:(NSDictionary *)conditions requireAll:(BOOL)requireAll sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSFetchRequest *fetch = [self fetchRequestWhere:conditions requireAll:requireAll sortBy:sortDescriptors limit:limit context:context];
    
    NSError *error = nil;
    NSArray *records = [context executeFetchRequest:fetch error:&error];
    
    if (records == nil)
    {
        if (error != nil && errorRef != nil) *errorRef = error;
        NSLog(@"%@: error fetching from core data: %@", self.class, [error userInfo]);
        return nil;
    }
    else
    {
        return records;
    }
}

+ (NSArray *)recordsWhere:(NSString *)predicateString arguments:(NSArray *)arguments sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSFetchRequest *fetch = [self fetchRequestWhere:predicateString arguments:arguments sortBy:sortDescriptors limit:limit context:context];
    
    NSError *error = nil;
    NSArray *records = [context executeFetchRequest:fetch error:&error];
    
    if (records == nil)
    {
        if (error != nil && errorRef != nil) *errorRef = error;
        NSLog(@"%@: error fetching from core data: %@", self.class, [error userInfo]);
        return nil;
    }
    else
    {
        return records;
    }
}

+ (instancetype)recordWhere:(NSDictionary *)conditions requireAll:(BOOL)requireAll sortBy:(NSArray *)sortDescriptors context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSError *error = nil;
    NSArray *records = [self recordsWhere:conditions requireAll:requireAll sortBy:sortDescriptors limit:1 context:context error:&error];
    
    if (records == nil)
    {
        if (error != nil && errorRef != nil) *errorRef = error;
        return nil;
    }
    else if (records.count > 0)
    {
        return [records objectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

+ (instancetype)recordWhere:(NSString *)predicateString arguments:(NSArray *)arguments sortBy:(NSArray *)sortDescriptors context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSError *error = nil;
    NSArray *records = [self recordsWhere:predicateString arguments:arguments sortBy:sortDescriptors limit:1 context:context error:&error];
    
    if (records == nil)
    {
        if (error != nil && errorRef != nil) *errorRef = error;
        return nil;
    }
    else if (records.count > 0)
    {
        return [records objectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

+ (NSFetchedResultsController *)fetchedResultsControllerWhere:(NSString *)predicateString arguments:(NSArray *)arguments sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [self fetchRequestWhere:predicateString arguments:arguments sortBy:sortDescriptors limit:limit context:context];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

+ (NSFetchedResultsController *)fetchedResultsControllerWhere:(NSDictionary *)conditions requireAll:(BOOL)requireAll sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [self fetchRequestWhere:conditions requireAll:requireAll sortBy:sortDescriptors limit:limit context:context];
    
    return [[NSFetchedResultsController alloc] initWithFetchRequest:fetch managedObjectContext:context sectionNameKeyPath:nil cacheName:nil];
}

+ (NSFetchRequest *)fetchRequestWhere:(NSString *)predicateString arguments:(NSArray *)arguments sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:predicateString argumentArray:arguments];
    
    return [self fetchRequestWithPredicate:predicate sortBy:sortDescriptors limit:limit context:context];
}

+ (NSFetchRequest *)fetchRequestWhere:(NSDictionary *)conditions requireAll:(BOOL)requireAll sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context
{
    NSPredicate *compoundPredicate = nil;
    
    if (conditions != nil && conditions.count > 0)
    {
        NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:[conditions count]];
        for (NSString *attributeName in conditions)
        {
            id value = [conditions objectForKey:attributeName];
            
            // This is a little bit crazy... you can't pass the attribute name in as an argument to predicateWithFormat:, so we're formatting the string twice...
            [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"(%@ == %%@)", attributeName], value]];
        }
        
        if (requireAll)
        {
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
        }
        else
        {
            compoundPredicate = [NSCompoundPredicate orPredicateWithSubpredicates:predicates];
        }
    }
    
    return [self fetchRequestWithPredicate:compoundPredicate sortBy:sortDescriptors limit:limit context:context];
}

+ (NSFetchRequest *)fetchRequestWithPredicate:(NSPredicate *)predicate sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context
{
    NSFetchRequest *fetch = [[NSFetchRequest alloc] init];
    
    fetch.entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
    
    if (predicate != nil)
    {
        fetch.predicate = predicate;
    }
    
    if (sortDescriptors != nil)
    {
        fetch.sortDescriptors = sortDescriptors;
    }
    
    fetch.fetchLimit = limit;
    
    return fetch;
}

- (NSDictionary *)dictionary
{
    return [self dictionaryWithValuesForKeys:self.entity.attributesByName.allKeys];
}

#pragma mark - Modifying

/**
 * Creates a new record of this class.
 */
+ (instancetype)newRecordInContext:(NSManagedObjectContext *)context
{
    ConvergeRecord *newRecord = [[self alloc]
                            initWithEntity:[NSEntityDescription entityForName:self.entityName inManagedObjectContext:context]
                            insertIntoManagedObjectContext:context];
    
    [context insertObject:newRecord];
    
    return newRecord;
}

+ (instancetype)newRecordWithProperties:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    ConvergeRecord *newRecord = [self newRecordInContext:context];
    
    NSArray *allAttributeNames = newRecord.entity.attributesByName.allKeys;
    NSArray *allRelationshipNames = newRecord.entity.relationshipsByName.allKeys;
    
    for (NSString *key in properties)
    {
        id value = TCKNullToNil(properties[key]);
        
        if ([allAttributeNames containsObject:key])
        {
            if ([self.class value:value isCorrectClassForAttributeName:key inContext:context])
            {
                [newRecord setValue:value forKey:key];
            }
            else
            {
                Class correctClass = [self.class classForAttributeName:key inContext:context];

                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"The record could not be created",
                    NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
                    ConvergeRecordUserInfoPropertyName: TCKNilToNull(key),
                    ConvergeRecordUserInfoExpectedClass: NSStringFromClass(correctClass),
                    ConvergeRecordUserInfoProvidedClass: NSStringFromClass([value class]),
                };
                NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeRecordErrorInvalidAttributeType userInfo:userInfo];
                if (errorRef != nil) *errorRef = error;
                
                [context deleteObject:newRecord];
                
                return nil;
            }
        }
        else if ([allRelationshipNames containsObject:key])
        {
            Class relationshipClass = [self classForRelationshipName:key context:context];
            
            if (value == nil || [value isKindOfClass:relationshipClass])
            {
                [newRecord setValue:value forKey:key];
            }
            else
            {
                NSDictionary *userInfo = @{
                    NSLocalizedDescriptionKey: @"The record could not be created",
                    NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
                    ConvergeRecordUserInfoPropertyName: TCKNilToNull(key),
                    ConvergeRecordUserInfoExpectedClass: NSStringFromClass(relationshipClass),
                    ConvergeRecordUserInfoProvidedClass: NSStringFromClass([value class]),
                };
                NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeRecordErrorInvalidRelationshipClass userInfo:userInfo];
                if (errorRef != nil) *errorRef = error;
                
                [context deleteObject:newRecord];
                
                return nil;
            }
        }
        else
        {
            NSDictionary *userInfo = @{
                NSLocalizedDescriptionKey: @"The record could not be created",
                NSLocalizedFailureReasonErrorKey: @"The provided data was not valid.",
                ConvergeRecordUserInfoPropertyName: TCKNilToNull(key),
            };
            NSError *error = [NSError errorWithDomain:ConvergeRecordErrorDomain code:ConvergeRecordErrorUnknownProperty userInfo:userInfo];
            if (errorRef != nil) *errorRef = error;
            
            [context deleteObject:newRecord];
            
            return nil;
        }
    }
    
    return newRecord;
}

- (instancetype)copyInContext:(NSManagedObjectContext *)newContext error:(NSError **)errorRef
{
    NSError *error = nil;
    ConvergeRecord *copy = [self.class newRecordWithProperties:self.dictionary inContext:newContext error:&error];
    if (error != nil && errorRef != nil) *errorRef = error;
    
    return copy;
}

+ (void)deleteSet:(NSMutableSet *)recordSet inContext:(NSManagedObjectContext *)context
{
    for (NSManagedObject *record in recordSet)
    {
        [context deleteObject:record];
    }
    
    [recordSet removeAllObjects];
}

+ (BOOL)deleteAllInContext:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSError *error = nil;
    NSArray *records = [self allRecordsSortedBy:nil context:context error:&error];
    if (records == nil && error != nil)
    {
        if (errorRef != nil) *errorRef = error;
        return NO;
    }
    else
    {
        for (ConvergeRecord *record in records)
        {
            [context deleteObject:record];
        }
        
        return YES;
    }
}

#pragma mark - Hybrid

+ (instancetype)newOrExistingRecordWithProperties:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSMutableArray *sort = [NSMutableArray arrayWithCapacity:attributes.count];
    for (NSString *key in attributes)
    {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key ascending:YES];
        [sort addObject:sortDescriptor];
    }
    
    NSError *error = nil;
    ConvergeRecord *record = [self recordWhere:attributes requireAll:YES sortBy:sort context:context error:&error];
    if (record == nil)
    {
        if (error == nil)
        {
            error = nil;
            record = [self newRecordWithProperties:attributes inContext:context error:&error];
            
            if (error != nil)
            {
                if (errorRef != nil) *errorRef = error;
                
                return nil;
            }
        }
        else
        {
            if (errorRef != nil) *errorRef = error;
            
            return nil;
        }
    }
    
    return record;
}

#pragma mark - Validating

/**
 * You would think that NSManagedObject -validateValue:forKey:error: would check for this kind of thing... but it doesn't
 */
+ (Class)classForAttribute:(NSAttributeDescription *)attribute
{
    switch (attribute.attributeType)
    {
        case NSInteger16AttributeType:
        case NSInteger32AttributeType:
        case NSInteger64AttributeType:
        case NSDecimalAttributeType:
        case NSDoubleAttributeType:
        case NSFloatAttributeType:
        case NSBooleanAttributeType:
            return NSNumber.class;
            
        case NSStringAttributeType:
            return NSString.class;
            
        case NSDateAttributeType:
            return NSDate.class;
            
        case NSBinaryDataAttributeType:
            return NSData.class;
            
        default:
            return NSObject.class;
    }
}

+ (Class)classForAttributeName:(NSString *)attributeName inContext:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
    NSAttributeDescription *attribute = [entity.attributesByName valueForKey:attributeName];
    
    if (attribute == nil)
    {
        TCKRaiseFormat(@"Attribute not found: %@ for entity: %@", attributeName, self.class);
    }
    
    return [self classForAttribute:attribute];
}

+ (BOOL)value:(id)value isCorrectClassForAttributeName:(NSString *)attributeName inContext:(NSManagedObjectContext *)context
{
    if (value == nil)
    {
        return YES;
    }
    else if ([value isKindOfClass:[self classForAttributeName:attributeName inContext:context]])
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Relationship info

/**
 * Returns the Class associated with a relationship on this class.
 */
+ (Class)classForRelationshipName:(NSString *)relationshipName context:(NSManagedObjectContext *)context
{
    NSEntityDescription *description = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
    NSDictionary *relationships = [description relationshipsByName];
    
    NSRelationshipDescription *relationship = [relationships objectForKey:relationshipName];
    if (relationship != nil)
    {
        return NSClassFromString(relationship.destinationEntity.managedObjectClassName);
    }
    else
    {
        return nil;
    }
}

@end
