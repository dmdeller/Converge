// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TestEntityFour.h instead.

@import CoreData;
#import "ConvergeRecord.h"

extern const struct TestEntityFourAttributes {
	__unsafe_unretained NSString *someFloat;
	__unsafe_unretained NSString *someString;
} TestEntityFourAttributes;

extern const struct TestEntityFourRelationships {
	__unsafe_unretained NSString *testEntityThrees;
	__unsafe_unretained NSString *testEntityTwos;
} TestEntityFourRelationships;

@class TestEntityThree;
@class TestEntityTwo;

@interface TestEntityFourID : NSManagedObjectID {}
@end

@interface _TestEntityFour : ConvergeRecord {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
@property (nonatomic, readonly, strong) TestEntityFourID* objectID;

@property (nonatomic, strong) NSNumber* someFloat;

@property (atomic) float someFloatValue;
- (float)someFloatValue;
- (void)setSomeFloatValue:(float)value_;

//- (BOOL)validateSomeFloat:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSString* someString;

//- (BOOL)validateSomeString:(id*)value_ error:(NSError**)error_;

@property (nonatomic, strong) NSOrderedSet *testEntityThrees;

- (NSMutableOrderedSet*)testEntityThreesSet;

@property (nonatomic, strong) NSOrderedSet *testEntityTwos;

- (NSMutableOrderedSet*)testEntityTwosSet;

@end

@interface _TestEntityFour (TestEntityThreesCoreDataGeneratedAccessors)
- (void)addTestEntityThrees:(NSOrderedSet*)value_;
- (void)removeTestEntityThrees:(NSOrderedSet*)value_;
- (void)addTestEntityThreesObject:(TestEntityThree*)value_;
- (void)removeTestEntityThreesObject:(TestEntityThree*)value_;

- (void)insertObject:(TestEntityThree*)value inTestEntityThreesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTestEntityThreesAtIndex:(NSUInteger)idx;
- (void)insertTestEntityThrees:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTestEntityThreesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTestEntityThreesAtIndex:(NSUInteger)idx withObject:(TestEntityThree*)value;
- (void)replaceTestEntityThreesAtIndexes:(NSIndexSet *)indexes withTestEntityThrees:(NSArray *)values;

@end

@interface _TestEntityFour (TestEntityTwosCoreDataGeneratedAccessors)
- (void)addTestEntityTwos:(NSOrderedSet*)value_;
- (void)removeTestEntityTwos:(NSOrderedSet*)value_;
- (void)addTestEntityTwosObject:(TestEntityTwo*)value_;
- (void)removeTestEntityTwosObject:(TestEntityTwo*)value_;

- (void)insertObject:(TestEntityTwo*)value inTestEntityTwosAtIndex:(NSUInteger)idx;
- (void)removeObjectFromTestEntityTwosAtIndex:(NSUInteger)idx;
- (void)insertTestEntityTwos:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeTestEntityTwosAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInTestEntityTwosAtIndex:(NSUInteger)idx withObject:(TestEntityTwo*)value;
- (void)replaceTestEntityTwosAtIndexes:(NSIndexSet *)indexes withTestEntityTwos:(NSArray *)values;

@end

@interface _TestEntityFour (CoreDataGeneratedPrimitiveAccessors)

- (NSNumber*)primitiveSomeFloat;
- (void)setPrimitiveSomeFloat:(NSNumber*)value;

- (float)primitiveSomeFloatValue;
- (void)setPrimitiveSomeFloatValue:(float)value_;

- (NSString*)primitiveSomeString;
- (void)setPrimitiveSomeString:(NSString*)value;

- (NSMutableOrderedSet*)primitiveTestEntityThrees;
- (void)setPrimitiveTestEntityThrees:(NSMutableOrderedSet*)value;

- (NSMutableOrderedSet*)primitiveTestEntityTwos;
- (void)setPrimitiveTestEntityTwos:(NSMutableOrderedSet*)value;

@end
