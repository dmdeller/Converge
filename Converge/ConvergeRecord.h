//
//  ConvergeRecord.h
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

static NSString *const ConvergeRecordErrorDomain = @"com.tripcraft.converge.record.error-domain";

typedef enum
{
    ConvergeRecordErrorUnknownProperty,
    ConvergeRecordErrorInvalidAttributeType,
    ConvergeRecordErrorInvalidRelationshipClass,
} ConvergeRecordError;

static NSString *const ConvergeRecordUserInfoPropertyName = @"com.tripcraft.converge.record.user-info.property-name";
static NSString *const ConvergeRecordUserInfoExpectedClass = @"com.tripcraft.converge.record.user-info.expected-class";
static NSString *const ConvergeRecordUserInfoProvidedClass = @"com.tripcraft.converge.record.user-info.actual-class";

@interface ConvergeRecord : NSManagedObject

/// @name Configuration
+ (NSString *)IDAttributeName;

///
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;

/// @name ID
- (NSString *)configuredID;
- (void)setConfiguredID:(NSString *)newConfiguredID;
- (BOOL)hasConfiguredID;
+ (BOOL)hasConfiguredIDInContext:(NSManagedObjectContext *)context;

/// @name Querying
+ (instancetype)recordForID:(id)theID context:(NSManagedObjectContext *)context error:(NSError **)errorRef;
+ (NSArray *)allRecordsSortedBy:(NSArray *)sortDescriptors context:(NSManagedObjectContext *)context error:(NSError **)errorRef;
+ (NSArray *)recordsWhere:(NSDictionary *)conditions requireAll:(BOOL)requireAll sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context error:(NSError **)errorRef;
+ (NSArray *)recordsWhere:(NSString *)predicateString arguments:(NSArray *)arguments sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context error:(NSError **)errorRef;
+ (instancetype)recordWhere:(NSDictionary *)conditions requireAll:(BOOL)requireAll sortBy:(NSArray *)sortDescriptors context:(NSManagedObjectContext *)context error:(NSError **)errorRef;
+ (instancetype)recordWhere:(NSString *)predicateString arguments:(NSArray *)arguments sortBy:(NSArray *)sortDescriptors context:(NSManagedObjectContext *)context error:(NSError **)errorRef;
+ (NSFetchedResultsController *)fetchedResultsControllerWhere:(NSString *)predicateString arguments:(NSArray *)arguments sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context;
+ (NSFetchedResultsController *)fetchedResultsControllerWhere:(NSDictionary *)conditions requireAll:(BOOL)requireAll sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)fetchRequestWhere:(NSDictionary *)conditions requireAll:(BOOL)requireAll sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)fetchRequestWithPredicate:(NSPredicate *)predicate sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context;
+ (NSFetchRequest *)fetchRequestWhere:(NSString *)predicateString arguments:(NSArray *)arguments sortBy:(NSArray *)sortDescriptors limit:(NSUInteger)limit context:(NSManagedObjectContext *)context;
- (NSDictionary *)dictionary;

/// @name Modifying
+ (instancetype)newRecordInContext:(NSManagedObjectContext *)context;
+ (instancetype)newRecordWithProperties:(NSDictionary *)properties inContext:(NSManagedObjectContext *)context error:(NSError **)errorRef;
- (instancetype)copyInContext:(NSManagedObjectContext *)newContext error:(NSError **)errorRef;
+ (void)deleteSet:(NSMutableSet *)recordSet inContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteAllInContext:(NSManagedObjectContext *)context error:(NSError **)errorRef;

/// @name Hybrid
+ (instancetype)newOrExistingRecordWithProperties:(NSDictionary *)attributes inContext:(NSManagedObjectContext *)context error:(NSError **)errorRef;

/// @name Validating
+ (Class)classForAttribute:(NSAttributeDescription *)attribute;
+ (Class)classForAttributeName:(NSString *)attributeName inContext:(NSManagedObjectContext *)context;
+ (BOOL)value:(id)value isCorrectClassForAttributeName:(NSString *)attributeName inContext:(NSManagedObjectContext *)context;

/// @name Relationship info
+ (Class)classForRelationshipName:(NSString *)relationshipName context:(NSManagedObjectContext *)context;

@end
