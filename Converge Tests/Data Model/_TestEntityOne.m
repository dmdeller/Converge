// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TestEntityOne.m instead.

#import "_TestEntityOne.h"

const struct TestEntityOneAttributes TestEntityOneAttributes = {
	.id = @"id",
	.someFloat = @"someFloat",
	.someString = @"someString",
};

const struct TestEntityOneRelationships TestEntityOneRelationships = {
	.testEntityThrees = @"testEntityThrees",
	.testEntityTwos = @"testEntityTwos",
};

@implementation TestEntityOneID
@end

@implementation _TestEntityOne

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TestEntityOne" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TestEntityOne";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TestEntityOne" inManagedObjectContext:moc_];
}

- (TestEntityOneID*)objectID {
	return (TestEntityOneID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"someFloatValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"someFloat"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}

@dynamic id;

- (int64_t)idValue {
	NSNumber *result = [self id];
	return [result longLongValue];
}

- (void)setIdValue:(int64_t)value_ {
	[self setId:@(value_)];
}

- (int64_t)primitiveIdValue {
	NSNumber *result = [self primitiveId];
	return [result longLongValue];
}

- (void)setPrimitiveIdValue:(int64_t)value_ {
	[self setPrimitiveId:@(value_)];
}

@dynamic someFloat;

- (float)someFloatValue {
	NSNumber *result = [self someFloat];
	return [result floatValue];
}

- (void)setSomeFloatValue:(float)value_ {
	[self setSomeFloat:@(value_)];
}

- (float)primitiveSomeFloatValue {
	NSNumber *result = [self primitiveSomeFloat];
	return [result floatValue];
}

- (void)setPrimitiveSomeFloatValue:(float)value_ {
	[self setPrimitiveSomeFloat:@(value_)];
}

@dynamic someString;

@dynamic testEntityThrees;

- (NSMutableOrderedSet*)testEntityThreesSet {
	[self willAccessValueForKey:@"testEntityThrees"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"testEntityThrees"];

	[self didAccessValueForKey:@"testEntityThrees"];
	return result;
}

@dynamic testEntityTwos;

- (NSMutableOrderedSet*)testEntityTwosSet {
	[self willAccessValueForKey:@"testEntityTwos"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"testEntityTwos"];

	[self didAccessValueForKey:@"testEntityTwos"];
	return result;
}

@end

@implementation _TestEntityOne (TestEntityThreesCoreDataGeneratedAccessors)
- (void)addTestEntityThrees:(NSOrderedSet*)value_ {
	[self.testEntityThreesSet unionOrderedSet:value_];
}
- (void)removeTestEntityThrees:(NSOrderedSet*)value_ {
	[self.testEntityThreesSet minusOrderedSet:value_];
}
- (void)addTestEntityThreesObject:(TestEntityThree*)value_ {
	[self.testEntityThreesSet addObject:value_];
}
- (void)removeTestEntityThreesObject:(TestEntityThree*)value_ {
	[self.testEntityThreesSet removeObject:value_];
}
- (void)insertObject:(TestEntityThree*)value inTestEntityThreesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityThrees"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityThrees]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityThrees"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityThrees"];
}
- (void)removeObjectFromTestEntityThreesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityThrees"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityThrees]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityThrees"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityThrees"];
}
- (void)insertTestEntityThrees:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityThrees"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityThrees]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityThrees"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityThrees"];
}
- (void)removeTestEntityThreesAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityThrees"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityThrees]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityThrees"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityThrees"];
}
- (void)replaceObjectInTestEntityThreesAtIndex:(NSUInteger)idx withObject:(TestEntityThree*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityThrees"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityThrees]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityThrees"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityThrees"];
}
- (void)replaceTestEntityThreesAtIndexes:(NSIndexSet *)indexes withTestEntityThrees:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityThrees"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityThrees]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityThrees"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityThrees"];
}
@end

@implementation _TestEntityOne (TestEntityTwosCoreDataGeneratedAccessors)
- (void)addTestEntityTwos:(NSOrderedSet*)value_ {
	[self.testEntityTwosSet unionOrderedSet:value_];
}
- (void)removeTestEntityTwos:(NSOrderedSet*)value_ {
	[self.testEntityTwosSet minusOrderedSet:value_];
}
- (void)addTestEntityTwosObject:(TestEntityTwo*)value_ {
	[self.testEntityTwosSet addObject:value_];
}
- (void)removeTestEntityTwosObject:(TestEntityTwo*)value_ {
	[self.testEntityTwosSet removeObject:value_];
}
- (void)insertObject:(TestEntityTwo*)value inTestEntityTwosAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityTwos"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityTwos]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityTwos"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityTwos"];
}
- (void)removeObjectFromTestEntityTwosAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityTwos"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityTwos]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityTwos"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityTwos"];
}
- (void)insertTestEntityTwos:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityTwos"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityTwos]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityTwos"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityTwos"];
}
- (void)removeTestEntityTwosAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityTwos"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityTwos]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityTwos"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityTwos"];
}
- (void)replaceObjectInTestEntityTwosAtIndex:(NSUInteger)idx withObject:(TestEntityTwo*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityTwos"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityTwos]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityTwos"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityTwos"];
}
- (void)replaceTestEntityTwosAtIndexes:(NSIndexSet *)indexes withTestEntityTwos:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityTwos"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityTwos]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityTwos"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityTwos"];
}
@end

