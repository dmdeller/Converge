//
//  ConvergeRecord+Mapping.h
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import "ConvergeRecord.h"

@interface ConvergeRecord (Mapping)

/// @name Configuration
+ (id)providerIDAttributeName;
+ (NSString *)collectionURLPathForHTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters;
+ (NSString *)URLPathForID:(id)recordID HTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters;
- (NSString *)URLPathForHTTPMethod:(NSString *)HTTPMethod parameters:(NSDictionary *)parameters;
+ (NSDictionary *)attributeMap;
+ (NSDictionary *)foreignKeyMap;
+ (NSDictionary *)relationshipMap;

/// @name Mapping
+ (NSDictionary *)attributeMapForProviderKeys:(NSArray *)providerKeys context:(NSManagedObjectContext *)context;
+ (NSDictionary *)foreignKeyMapForProviderKeys:(NSArray *)providerKeys context:(NSManagedObjectContext *)context;
+ (NSDictionary *)relationshipMapForProviderKeys:(NSArray *)providerKeys context:(NSManagedObjectContext *)context;
+ (NSString *)attributeNameForProviderAttributeName:(id)providerAttributeName context:(NSManagedObjectContext *)context;
+ (NSString *)relationshipNameForProviderForeignKeyName:(id)providerForeignKeyName context:(NSManagedObjectContext *)context;
+ (NSString *)relationshipNameForProviderRelationshipName:(id)providerRelationshipName context:(NSManagedObjectContext *)context;
+ (NSString *)inferredProviderForeignKeyNameForRelationship:(NSRelationshipDescription *)relationship;
+ (NSValueTransformer *)providerNameTransformer;
+ (NSValueTransformer *)ourNameTransformer;

/// @name Querying
+ (NSArray *)recordsFromQuery:(NSDictionary *)params sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context error:(NSError **)errorRef;
+ (NSFetchRequest *)fetchRequestWithQuery:(NSDictionary *)params sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context;
+ (NSPredicate *)predicateForQuery:(NSDictionary *)params context:(NSManagedObjectContext *)context;

/// @name Relationship info
- (NSString *)inverseForeignKeyForRelationshipName:(NSString *)relationshipName;

@end
