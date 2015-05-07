// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TestEntityThree.m instead.

#import "_TestEntityThree.h"

const struct TestEntityThreeAttributes TestEntityThreeAttributes = {
	.id = @"id",
	.someFloat = @"someFloat",
	.someString = @"someString",
};

const struct TestEntityThreeRelationships TestEntityThreeRelationships = {
	.testEntityOnes = @"testEntityOnes",
};

@implementation TestEntityThreeID
@end

@implementation _TestEntityThree

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TestEntityThree" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TestEntityThree";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TestEntityThree" inManagedObjectContext:moc_];
}

- (TestEntityThreeID*)objectID {
	return (TestEntityThreeID*)[super objectID];
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

@dynamic testEntityOnes;

- (NSMutableOrderedSet*)testEntityOnesSet {
	[self willAccessValueForKey:@"testEntityOnes"];

	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"testEntityOnes"];

	[self didAccessValueForKey:@"testEntityOnes"];
	return result;
}

@end

@implementation _TestEntityThree (TestEntityOnesCoreDataGeneratedAccessors)
- (void)addTestEntityOnes:(NSOrderedSet*)value_ {
	[self.testEntityOnesSet unionOrderedSet:value_];
}
- (void)removeTestEntityOnes:(NSOrderedSet*)value_ {
	[self.testEntityOnesSet minusOrderedSet:value_];
}
- (void)addTestEntityOnesObject:(TestEntityOne*)value_ {
	[self.testEntityOnesSet addObject:value_];
}
- (void)removeTestEntityOnesObject:(TestEntityOne*)value_ {
	[self.testEntityOnesSet removeObject:value_];
}
- (void)insertObject:(TestEntityOne*)value inTestEntityOnesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityOnes"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityOnes]];
    [tmpOrderedSet insertObject:value atIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityOnes"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityOnes"];
}
- (void)removeObjectFromTestEntityOnesAtIndex:(NSUInteger)idx {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityOnes"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityOnes]];
    [tmpOrderedSet removeObjectAtIndex:idx];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityOnes"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityOnes"];
}
- (void)insertTestEntityOnes:(NSArray *)value atIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityOnes"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityOnes]];
    [tmpOrderedSet insertObjects:value atIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityOnes"];
    [self didChange:NSKeyValueChangeInsertion valuesAtIndexes:indexes forKey:@"testEntityOnes"];
}
- (void)removeTestEntityOnesAtIndexes:(NSIndexSet *)indexes {
    [self willChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityOnes"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityOnes]];
    [tmpOrderedSet removeObjectsAtIndexes:indexes];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityOnes"];
    [self didChange:NSKeyValueChangeRemoval valuesAtIndexes:indexes forKey:@"testEntityOnes"];
}
- (void)replaceObjectInTestEntityOnesAtIndex:(NSUInteger)idx withObject:(TestEntityOne*)value {
    NSIndexSet* indexes = [NSIndexSet indexSetWithIndex:idx];
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityOnes"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityOnes]];
    [tmpOrderedSet replaceObjectAtIndex:idx withObject:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityOnes"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityOnes"];
}
- (void)replaceTestEntityOnesAtIndexes:(NSIndexSet *)indexes withTestEntityOnes:(NSArray *)value {
    [self willChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityOnes"];
    NSMutableOrderedSet *tmpOrderedSet = [NSMutableOrderedSet orderedSetWithOrderedSet:[self testEntityOnes]];
    [tmpOrderedSet replaceObjectsAtIndexes:indexes withObjects:value];
    [self setPrimitiveValue:tmpOrderedSet forKey:@"testEntityOnes"];
    [self didChange:NSKeyValueChangeReplacement valuesAtIndexes:indexes forKey:@"testEntityOnes"];
}
@end

