//
//  NSArray+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 8/29/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSArray+TripCraftKit.h"

#import "NSMutableArray+TripCraftKit.h"

@implementation NSArray (TripCraftKit)

- (id)firstObject_tc
{
    if (self.count > 0)
    {
        return [self objectAtIndex:0];
    }
    else
    {
        return nil;
    }
}

#pragma mark -

/**
 * Calls block once for each element in self, passing that element as a parameter.
 */
- (void)each_tc:(void (^)(id value))iterate
{
    for (id value in self)
    {
        iterate(value);
    }
}

/**
 * Same as -each_tc, but passes the index of the element in addition to the element itself.
 */
- (void)eachIndex_tc:(void (^)(NSUInteger index, id value))iterate
{
    __block NSUInteger index = 0;
    
    [self each_tc:^(id value)
     {
         iterate(index, value);
         
         index += 1;
     }];
}

/**
 * Invokes block once for each element of self. Creates a new array containing the values returned by the block.
 */
- (NSArray *)arrayByCollecting_tc:(id (^)(id value))iterate
{
    NSMutableArray *newArray = [NSMutableArray arrayWithCapacity:self.count];
    
    [self each_tc:^(id value)
     {
         id newValue = iterate(value);
         
         if (newValue != nil)
         {
             [newArray addObject:newValue];
         }
     }];
    
    return newArray.immutableCopy_tc;
}

- (NSArray *)arrayWithoutRejectedValues_tc:(BOOL (^)(id value))shouldReject
{
    return [self arrayByCollecting_tc:^id(id value)
     {
         if (shouldReject(value))
         {
             return nil;
         }
         else
         {
             return value;
         }
     }];
}

- (NSArray *)uniqueValues_tc
{
    NSMutableArray *uniqueArray = [NSMutableArray arrayWithCapacity:self.count];
    
    [self each_tc:^(id value)
     {
         if (![uniqueArray containsObject:value])
         {
             [uniqueArray addObject:value];
         }
     }];
    
    return uniqueArray.immutableCopy_tc;
}

- (BOOL)containsObjects_tc:(NSArray *)objects
{
    for (id object in objects)
    {
        if (![self containsObject:object])
        {
            return NO;
        }
    }
    
    return YES;
}

- (NSArray *)differenceFromArray_tc:(NSArray *)array
{
    NSMutableArray *difference = NSMutableArray.new;
    
    for (id<NSCopying> object in self)
    {
        if (![array containsObject:object])
        {
            [difference addObject:object];
        }
    }
    
    return difference.immutableCopy_tc;
}

@end
