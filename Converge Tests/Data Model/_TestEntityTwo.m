// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to TestEntityTwo.m instead.

#import "_TestEntityTwo.h"

const struct TestEntityTwoAttributes TestEntityTwoAttributes = {
	.id = @"id",
	.someDate = @"someDate",
	.someDecimal = @"someDecimal",
};

const struct TestEntityTwoRelationships TestEntityTwoRelationships = {
	.testEntityOne = @"testEntityOne",
};

@implementation TestEntityTwoID
@end

@implementation _TestEntityTwo

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TestEntityTwo" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TestEntityTwo";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TestEntityTwo" inManagedObjectContext:moc_];
}

- (TestEntityTwoID*)objectID {
	return (TestEntityTwoID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];

	if ([key isEqualToString:@"idValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"id"];
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

@dynamic someDate;

@dynamic someDecimal;

@dynamic testEntityOne;

@end

