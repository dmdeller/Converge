//
//  NSSet+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 1/14/14.
//  Copyright (c) 2014 TripCraft. All rights reserved.
//

#import "NSSet+TripCraftKit.h"

@implementation NSSet (TripCraftKit)

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

@end
