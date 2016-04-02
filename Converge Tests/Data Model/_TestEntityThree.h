// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TestEntityThree.h instead.

@import CoreData;
#import "ConvergeRecord.h"

extern const struct TestEntityThreeAttributes {
	__unsafe_unretained NSString *id;
	__unsafe_unretained NSString *someFloat;
	__unsafe_unretained NSString *someString;
} TestEntityThreeAttributes;

extern const struct TestEntityThreeRelationships {
	__unsafe_unretained NSString *testEntityFours;
	__unsafe_unretained NSString *testEntityOnes;
} TestEntityThreeRelationships;

@class TestEntityFour;
@class TestEntityOne;

@interface TestEntityThreeID : NSManagedObjectID {}
@end

@interface _TestEntityThree : ConvergeRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TestEntityThreeID* objectID;

@property (nonatomic, strong) NSNumber* id;

@property (atomic) int64_t idValue;
- (int64_t)idValue;
- (void)setIdValue:(int64_t)value_;

//- (BOOL)validateId:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSNumber* someFloat;

@property (atomic) float someFloatValue;
- (float)someFloatValue;
- (void)setSomeFloatValue:(float)value_;

//- (BOOL)validateSomeFloat:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* someString;

//- (BOOL)validateSomeString:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSOrderedSet *testEntityFours;

- (NSMutableOrderedSet*)testEntityFoursSet;

@property (nonatomic, strong) NSOrderedSet *testEntityOnes;

- (NSMutableOrderedSet*)testEntityOnesSet;

@end

@interface _TestEntityThree (TestEntityFoursCoreDataGeneratedAccessors)
- (void)addTestEntityFours:(NSOrderedSet*)value_;
- (void)removeTestEntityFours:(NSOrderedSet*)value_;
- (void)addTestEntityFoursObject:(TestEntityFour*)value_;
- (void)removeTestEntityFoursObject:(TestEntityFour*)value_;

- (void)insertObject:(TestEntityFour*)value inTestEntityFoursAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTestEntityFoursAtIndex:(NSUInteger)idx;
- (void)insertTestEntityFours:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTestEntityFoursAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTestEntityFoursAtIndex:(NSUInteger)idx withObject:(TestEntityFour*)value;
- (void)replaceTestEntityFoursAtIndexes:(NSIndexSet *)indexes withTestEntityFours:(NSArray *)values;

@end

@interface _TestEntityThree (TestEntityOnesCoreDataGeneratedAccessors)
- (void)addTestEntityOnes:(NSOrderedSet*)value_;
- (void)removeTestEntityOnes:(NSOrderedSet*)value_;
- (void)addTestEntityOnesObject:(TestEntityOne*)value_;
- (void)removeTestEntityOnesObject:(TestEntityOne*)value_;

- (void)insertObject:(TestEntityOne*)value inTestEntityOnesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTestEntityOnesAtIndex:(NSUInteger)idx;
- (void)insertTestEntityOnes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTestEntityOnesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTestEntityOnesAtIndex:(NSUInteger)idx withObject:(TestEntityOne*)value;
- (void)replaceTestEntityOnesAtIndexes:(NSIndexSet *)indexes withTestEntityOnes:(NSArray *)values;

@end

@interface _TestEntityThree (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveId;
- (void)setPrimitiveId:(NSNumber*)value;

- (int64_t)primitiveIdValue;
- (void)setPrimitiveIdValue:(int64_t)value_;

- (NSNumber*)primitiveSomeFloat;
- (void)setPrimitiveSomeFloat:(NSNumber*)value;

- (float)primitiveSomeFloatValue;
- (void)setPrimitiveSomeFloatValue:(float)value_;

- (NSString*)primitiveSomeString;
- (void)setPrimitiveSomeString:(NSString*)value;

- (NSMutableOrderedSet*)primitiveTestEntityFours;
- (void)setPrimitiveTestEntityFours:(NSMutableOrderedSet*)value;

- (NSMutableOrderedSet*)primitiveTestEntityOnes;
- (void)setPrimitiveTestEntityOnes:(NSMutableOrderedSet*)value;

@end
