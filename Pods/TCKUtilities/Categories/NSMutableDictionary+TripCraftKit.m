//
//  NSMutableDictionary+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 9/26/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSMutableDictionary+TripCraftKit.h"

@implementation NSMutableDictionary (TripCraftKit)

- (NSDictionary *)immutableCopy_tc
{
    return [NSDictionary dictionaryWithDictionary:self];
}

/**
 * Like in NSMutableArray; removes all occurrences in the dictionary of a given object.
 */
- (void)removeObject_tc:(id)object
{
    NSDictionary *copy = self.immutableCopy_tc;
    
    for (id key in copy)
    {
        id anObject = copy[key];
        
        if (anObject == object || [anObject isEqual:object])
        {
            [self removeObjectForKey:key];
        }
    }
}

@end
