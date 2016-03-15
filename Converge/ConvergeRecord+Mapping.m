//
//  ConvergeRecord+Mapping.m
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import "ConvergeRecord+Mapping.h"

#import <TransformerKit/TTTStringTransformers.h>
#import <InflectorKit/TTTStringInflector.h>
#import <TCKUtilities/TCKCategories.h>

@implementation ConvergeRecord (Mapping)

#pragma mark - Configuration

/**
 * Override if provider's ID has a different name (e.g. public_id)
 */
+ (id)providerIDAttributeName
{
    id mappedID = self.attributeMap[self.IDAttributeName];
    
    if (mappedID != nil)
    {
        return mappedID;
    }
    else
    {
        return self.IDAttributeName;
    }
}

/**
 * Relative URL path to fetch JSON data for a collection of records of this class from the provider.
 */
+ (NSString *)collectionURLPathForHTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters
{
    NSValueTransformer *camelCaseTransformer = [NSValueTransformer valueTransformerForName:TTTCamelCaseStringTransformerName];
    NSValueTransformer *snakeCaseTransformer = [NSValueTransformer valueTransformerForName:TTTSnakeCaseStringTransformerName];
    
    return [NSString stringWithFormat:@"/%@",
            [TTTStringInflector.defaultInflector pluralize:[snakeCaseTransformer transformedValue:[camelCaseTransformer reverseTransformedValue:self.entityName]]]];
}

/**
 * Relative URL path to fetch JSON data for a record of this class from the provider.
 */
+ (NSString *)URLPathForID:(id)recordID HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters
{
    NSValueTransformer *camelCaseTransformer = [NSValueTransformer valueTransformerForName:TTTCamelCaseStringTransformerName];
    NSValueTransformer *snakeCaseTransformer = [NSValueTransformer valueTransformerForName:TTTSnakeCaseStringTransformerName];
    
    return [NSString stringWithFormat:@"/%@/%@",
            [TTTStringInflector.defaultInflector pluralize:[snakeCaseTransformer transformedValue:[camelCaseTransformer reverseTransformedValue:self.entityName]]],
            recordID];
}

/**
 * Relative URL path to fetch JSON data for a record of this class from the provider.
 */
- (NSString *)URLPathForHTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters
{
    return [self.class URLPathForID:self.configuredID HTTPMethod:HTTPMethod parameters:parameters];
}

/**
 * Maps provider attributes to Core Data attributes
 *
 * If not specified, TCKRecord will try to figure out the mapping automatically, first by looking for identical names, then by looking for snake_cased equivalents of llamaCased names.
 */
+ (NSDictionary *)attributeMap
{
    return @{};
}

/**
 * Maps provider foreign key attributes to Core Data relationships (if any)
 *
 * This is similar to relationshipMap, but it is expected that the provider will give us only a key instead of the full object.
 */
+ (NSDictionary *)foreignKeyMap
{
    return @{};
}

/**
 * Maps provider collections to Core Data relationships (if any)
 */
+ (NSDictionary *)relationshipMap
{
    return @{};
}

/**
 * When sending a new or updated record (as POST or PATCH, respectively), this method determines whether or not to wrap the record data in outer object with the entity name.
 * 
 * YES example:
 * {"record": {"foo": 1, "bar": 2}}
 *
 * NO example:
 * {"foo": 1, "bar" 2}
 */
+ (BOOL)shouldWrapRequestBody
{
    return YES;
}

#pragma mark - Mapping Logic

+ (NSDictionary *)attributeMapForProviderKeys:(NSArray *)providerKeys context:(NSManagedObjectContext *)context
{
    NSMutableDictionary *map = [self mapForProviderKeys:providerKeys configuredMap:self.attributeMap automaticNameBlock:^NSString *(id providerKey)
     {
         return [self inferredAttributeNameForProviderAttributeName:providerKey context:context];
     }
    context:context].mutableCopy;
    
    map[self.IDAttributeName] = self.providerIDAttributeName;
    
    return map.immutableCopy_tc;
}

+ (NSDictionary *)foreignKeyMapForProviderKeys:(NSArray *)providerKeys context:(NSManagedObjectContext *)context
{
    return [self mapForProviderKeys:providerKeys configuredMap:self.foreignKeyMap automaticNameBlock:^NSString *(id providerKey)
     {
         return [self inferredRelationshipNameForProviderForeignKeyName:providerKey context:context];
     }
    context:context];
}

+ (NSDictionary *)relationshipMapForProviderKeys:(NSArray *)providerKeys context:(NSManagedObjectContext *)context
{
    return [self mapForProviderKeys:providerKeys configuredMap:self.relationshipMap automaticNameBlock:^NSString *(id providerKey)
     {
         return [self inferredRelationshipNameForProviderRelationshipName:providerKey context:context];
     }
    context:context];
}

+ (NSDictionary *)mapForProviderKeys:(NSArray *)providerKeys configuredMap:(NSDictionary *)configuredMap automaticNameBlock:(NSString *(^)(id providerKey))automaticNameBlock context:(NSManagedObjectContext *)context
{
    NSMutableDictionary *map = NSMutableDictionary.new;
    
    for (id providerKey in providerKeys)
    {
        NSString *ourKey = automaticNameBlock(providerKey);
        if (ourKey != nil && map[ourKey] == nil)
        {
            map[ourKey] = providerKey;
        }
    }
    
    if (configuredMap != nil)
    {
        // Explicitly configured mappings override automatically inferred ones
        [map addEntriesFromDictionary:configuredMap];
    }
    
    return map.immutableCopy_tc;
}

+ (NSString *)attributeNameForProviderAttributeName:(id)providerAttributeName context:(NSManagedObjectContext *)context
{
    NSString *ourAttributeName = [self.class.attributeMap allKeysForObject:providerAttributeName].firstObject_tc;
    if (ourAttributeName != nil)
    {
        return ourAttributeName;
    }
    
    return [self inferredAttributeNameForProviderAttributeName:providerAttributeName context:context];
}

+ (NSString *)inferredAttributeNameForProviderAttributeName:(id)providerAttributeName context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
    return [self similarNameForProviderName:providerAttributeName inNames:entity.attributesByName.allKeys];
}

+ (NSString *)relationshipNameForProviderForeignKeyName:(id)providerForeignKeyName context:(NSManagedObjectContext *)context
{
    NSString *ourRelationshipName = [self.class.foreignKeyMap allKeysForObject:providerForeignKeyName].firstObject_tc;
    if (ourRelationshipName != nil)
    {
        return ourRelationshipName;
    }
    
    return [self inferredRelationshipNameForProviderForeignKeyName:providerForeignKeyName context:context];
}

+ (NSString *)inferredRelationshipNameForProviderForeignKeyName:(id)providerForeignKeyName context:(NSManagedObjectContext *)context
{
    NSString *IDRegEx = @"(_id|ID|Id)s?$";
    if ([providerForeignKeyName matchesRegEx:IDRegEx options_tc:0])
    {
        BOOL isPlural = [providerForeignKeyName matchesRegEx:@"s$" options_tc:0];
        
        NSString *providerRelationshipName = providerForeignKeyName;
        providerRelationshipName = [providerForeignKeyName stringByReplacingOccurrencesOfRegEx:IDRegEx withTemplate:@"" options_tc:0];
        
        if (isPlural)
        {
            providerRelationshipName = [TTTStringInflector.defaultInflector pluralize:providerRelationshipName];
        }
        
        return [self inferredRelationshipNameForProviderRelationshipName:providerRelationshipName context:context];
    }
    else
    {
        return nil;
    }
}

+ (NSString *)relationshipNameForProviderRelationshipName:(id)providerRelationshipName context:(NSManagedObjectContext *)context
{
    NSString *ourRelationshipName = [self.class.relationshipMap allKeysForObject:providerRelationshipName].firstObject_tc;
    if (ourRelationshipName != nil)
    {
        return ourRelationshipName;
    }
    
    return [self inferredRelationshipNameForProviderRelationshipName:providerRelationshipName context:context];
}

+ (NSString *)inferredRelationshipNameForProviderRelationshipName:(id)providerRelationshipName context:(NSManagedObjectContext *)context
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
    return [self similarNameForProviderName:providerRelationshipName inNames:entity.relationshipsByName.allKeys];
}

+ (NSString *)similarNameForProviderName:(NSString *)providerName inNames:(NSArray *)ourNames
{
    if ([ourNames containsObject:providerName])
    {
        return providerName;
    }
    
    NSString *transformedName = [self.ourNameTransformer transformedValue:[self.providerNameTransformer reverseTransformedValue:providerName]];
    
    if ([ourNames containsObject:transformedName])
    {
        return transformedName;
    }
    
    return nil;
}

+ (NSValueTransformer *)providerNameTransformer
{
    return [NSValueTransformer valueTransformerForName:TTTSnakeCaseStringTransformerName];
}

+ (NSValueTransformer *)ourNameTransformer
{
    return [NSValueTransformer valueTransformerForName:TTTLlamaCaseStringTransformerName];
}

+ (NSString *)inferredProviderForeignKeyNameForRelationship:(NSRelationshipDescription *)relationship
{
    NSString *suffix = nil;
    if (relationship.isToMany)
    {
        suffix = @"ids";
    }
    else
    {
        suffix = @"id";
    }
    
    NSString *ourKey = relationship.name;
    NSString *providerKey = [self.providerNameTransformer transformedValue:[NSString stringWithFormat:@"%@ %@", [self.ourNameTransformer reverseTransformedValue:ourKey], suffix]];
    
    return providerKey;
}

#pragma mark - Querying based on mappings

+ (NSArray *)recordsFromQuery:(NSDictionary *)params sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context error:(NSError **)errorRef
{
    NSFetchRequest *fetch = [self fetchRequestWithQuery:params sortBy:sortDescriptors limit:limit context:context];
    
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

+ (NSFetchRequest *)fetchRequestWithQuery:(NSDictionary *)params sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context
{
    return [self fetchRequestWithPredicate:[self predicateForQuery:params context:context] sortBy:sortDescriptors limit:limit context:context];
}

/**
 * Transforms a set of query parameters into an NSPredicate that can be used for querying.
 */
+ (NSPredicate *)predicateForQuery:(NSDictionary *)params context:(NSManagedObjectContext *)context
{
    if (params == nil)
    {
        return nil;
    }
    
    NSMutableArray *predicates = [NSMutableArray arrayWithCapacity:5];
    
    NSDictionary *attributeMap = [self.class attributeMapForProviderKeys:params.allKeys context:context];
    NSDictionary *foreignKeyMap = [self.class foreignKeyMapForProviderKeys:params.allKeys context:context];
    
    NSEntityDescription *entity = [NSEntityDescription entityForName:self.entityName inManagedObjectContext:context];
    NSDictionary *relationships = entity.relationshipsByName;
    
    for (NSString *ourKey in attributeMap)
    {
        id providerKey = attributeMap[ourKey];
        
        if ([providerKey isKindOfClass:NSString.class] && [params.allKeys containsObject:providerKey])
        {
            id value = params[providerKey];
            [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = %%@", ourKey], value]];
        }
    }
    
    for (NSString *ourKey in foreignKeyMap)
    {
        id providerKey = foreignKeyMap[ourKey];
        
        if ([providerKey isKindOfClass:NSString.class] && [params.allKeys containsObject:providerKey])
        {
            id foreignId = [params objectForKey:providerKey];
            Class foreignClass = [self classForRelationshipName:ourKey context:context];
            
            NSError *error = nil;
            id value = [foreignClass recordForID:foreignId context:context error:&error];
            
            if (value != nil)
            {
                NSRelationshipDescription *relationship = relationships[ourKey];
                
                if (relationship.isToMany)
                {
                    [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%%@ IN %@", ourKey], value]];
                }
                else
                {
                    [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ = %%@", ourKey], value]];
                }
            }
            else
            {
                NSLog(@"%@: unable to transform query param into predicate because %@ with id %@ was not found, query: %@", self.class, ourKey, foreignId, params);
            }
        }
    }
    
    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

#pragma mark - Relationship info

/*
 * Given a relationship on this class, returns the name of the provider's foreign key that represents this relationship on the destination class
 */
- (NSString *)inverseForeignKeyForRelationshipName:(NSString *)relationshipName
{
    NSRelationshipDescription *relationship = self.entity.relationshipsByName[relationshipName];
    Class relationshipRecordClass = [[self class] classForRelationshipName:relationshipName context:[self managedObjectContext]];
    NSString *inverseName = relationship.inverseRelationship.name;
    NSString *inverseForeignKey = [[[relationshipRecordClass foreignKeyMap] allKeysForObject:inverseName] objectAtIndex:0];
    
    return inverseForeignKey;
}

@end
