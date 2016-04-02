// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TestEntityTwo.h instead.

@import CoreData;
#import "ConvergeRecord.h"

extern const struct TestEntityTwoAttributes {
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *someDate;
	__unsafe_unretained NSString *someDecimal;
} TestEntityTwoAttributes;

extern const struct TestEntityTwoRelationships {
	__unsafe_unretained NSString *testEntityFour;
	__unsafe_unretained NSString *testEntityOne;
} TestEntityTwoRelationships;

@class TestEntityFour;
@class TestEntityOne;

@interface TestEntityTwoID : NSManagedObjectID {}
@end

@interface _TestEntityTwo : ConvergeRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TestEntityTwoID* objectID;

@property (nonatomic, strong) NSNumber* id;

@property (atomic) int64_t idValue;
- (int64_t)idValue;
- (void)setIdValue:(int64_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDate* someDate;

//- (BOOL)validateSomeDate:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSDecimalNumber* someDecimal;

//- (BOOL)validateSomeDecimal:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) TestEntityFour *testEntityFour;

//- (BOOL)validateTestEntityFour:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) TestEntityOne *testEntityOne;

//- (BOOL)validateTestEntityOne:(id*)value_ error:(NSError**)error_;

@end

@interface _TestEntityTwo (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int64_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int64_t)value_;

- (NSDate*)primitiveSomeDate;
- (void)setPrimitiveSomeDate:(NSDate*)value;

- (NSDecimalNumber*)primitiveSomeDecimal;
- (void)setPrimitiveSomeDecimal:(NSDecimalNumber*)value;

- (TestEntityFour*)primitiveTestEntityFour;
- (void)setPrimitiveTestEntityFour:(TestEntityFour*)value;

- (TestEntityOne*)primitiveTestEntityOne;
- (void)setPrimitiveTestEntityOne:(TestEntityOne*)value;

@end
