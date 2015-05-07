//
//  NSMutableSet+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 1/14/14.
//  Copyright (c) 2014 TripCraft. All rights reserved.
//

#import "NSMutableSet+TripCraftKit.h"

@implementation NSMutableSet (TripCraftKit)

- (NSSet *)immutableCopy_tc
{
    return [NSSet setWithSet:self];
}

@end
