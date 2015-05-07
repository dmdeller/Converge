//
//  NSMutableOrderedSet+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 1/2/14.
//  Copyright (c) 2014 TripCraft. All rights reserved.
//

#import "NSMutableOrderedSet+TripCraftKit.h"

@implementation NSMutableOrderedSet (TripCraftKit)

- (NSOrderedSet *)immutableCopy_tc
{
    return [NSOrderedSet orderedSetWithOrderedSet:self];
}

@end
