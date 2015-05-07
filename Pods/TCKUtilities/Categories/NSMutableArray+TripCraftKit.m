//
//  NSMutableArray+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 8/29/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSMutableArray+TripCraftKit.h"

@implementation NSMutableArray (TripCraftKit)

- (NSArray *)immutableCopy_tc
{
    return [NSArray arrayWithArray:self];
}

@end
