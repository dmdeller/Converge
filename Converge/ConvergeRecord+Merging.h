//
//  ConvergeRecord+Merging.h
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import "ConvergeRecord.h"
#import "ConvergeRecord+Mapping.h"

static NSString *const ConvergeMergeableRecordErrorDomain = @"com.tripcraft.converge.record.mergeable.error-domain";

typedef enum
{
    ConvergeMergeableRecordErrorFailedValidation,
    ConvergeMergeableRecordErrorProviderIDMissing,
    ConvergeMergeableRecordErrorProviderIDWrongType,
    ConvergeMergeableRecordErrorProviderAttributeWrongType,
    ConvergeMergeableRecordErrorExpectedConvergeRecord,
    ConvergeMergeableRecordErrorExpectedCollection,
    ConvergeMergeableRecordErrorProviderToManyLocalToOne,
    ConvergeMergeableRecordErrorMultipleErrors,
    ConvergeMergeableRecordErrorLocalRecordNotFound,
} ConvergeMergeableRecordError;

static NSString *const ConvergeMergeableRecordUserInfoLogMessage = @"com.tripcraft.converge.record.mergeable.user-info.log-message";
static NSString *const ConvergeMergeableRecordUserInfoRecord = @"com.tripcraft.converge.record.mergeable.user-info.record";
static NSString *const ConvergeMergeableRecordUserInfoProviderData = @"com.tripcraft.converge.record.mergeable.user-info.provider-data";
static NSString *const ConvergeMergeableRecordUserInfoExpected = @"com.tripcraft.converge.record.mergeable.user-info.expected";
static NSString *const ConvergeMergeableRecordUserInfoActual = @"com.tripcraft.converge.record.mergeable.user-info.actual";
static NSString *const ConvergeMergeableRecordUserInfoOriginalError = @"com.tripcraft.converge.record.mergeable.user-info.original-error";
static NSString *const ConvergeMergeableRecordUserInfoValidationType = @"com.tripcraft.converge.record.mergeable.user-info.validation-type";
static NSString *const ConvergeMergeableRecordUserInfoChangedValues = @"com.tripcraft.converge.record.mergeable.user-info.changed-values";

typedef enum
{
    ConvergeMergeableRecordValidationTypeUnknown = -1,
    ConvergeMergeableRecordValidationTypeInsert = 0,
    ConvergeMergeableRecordValidationTypeUpdate,
} ConvergeMergeableRecordValidationType;

typedef id (^ConvergeAttributeConversionBlock)(id value);

@interface ConvergeRecord (Merging)

+ (BOOL)shouldFetchWithLastUpdatedTime:(NSDate *)updatedAt;

+ (BOOL)shouldExportAttribute:(NSString *)attributeName;

+ (ConvergeAttributeConversionBlock)conversionForAttribute:(NSString *)ourAttributeName;
+ (ConvergeAttributeConversionBlock)reverseConversionForAttribute:(NSString *)ourAttributeName;

+ (ConvergeAttributeConversionBlock)stringToIntegerConversion;
+ (ConvergeAttributeConversionBlock)stringToFloatConversion;
+ (ConvergeAttributeConversionBlock)stringToDecimalConversion;
+ (ConvergeAttributeConversionBlock)stringToDateConversion;
+ (ConvergeAttributeConversionBlock)stringToURLConversion;
+ (ConvergeAttributeConversionBlock)URLToStringConversion;

/// @name Importing Data From Provider
- (BOOL)mergeChangesFromProvider:(NSDictionary *)providerRecord withQuery:(NSDictionary *)query recursive:(BOOL)recursive error:(NSError **)errorRef;
+ (instancetype)mergeChangesFromProvider:(NSDictionary *)providerRecord withQuery:(NSDictionary *)query recursive:(BOOL)recursive context:(NSManagedObjectContext *)context error:(NSError **)errorRef;
+ (NSArray *)mergeChangesFromProviderCollection:(NSArray *)collection withQuery:(NSDictionary *)query recursive:(BOOL)recursive deleteStale:(BOOL)shouldDeleteStale context:(NSManagedObjectContext *)context skipInvalidRecords:(BOOL)skipInvalid error:(NSError **)errorRef;

/// @name Exporting Data to Other Formats
+ (NSString *)providerClassName;
- (NSDictionary *)providerDictionary;
- (NSData *)providerJSON;

+ (NSString *)convertedID:(id)theID;

@end
