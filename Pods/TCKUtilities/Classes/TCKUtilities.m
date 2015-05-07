//
//  TCKUtilities.m
//  TCKUtilities
//
//  Created by David (work) on 7/24/14.
//  Copyright (c) 2014 TripCraft. All rights reserved.
//

#import "TCKUtilities.h"

@implementation TCKUtilities

id TCKNilToNull(id object)
{
    if (object == nil)
    {
        return NSNull.null;
    }
    else
    {
        return object;
    }
}

id TCKNullToNil(id object)
{
    if ([object isKindOfClass:NSNull.class])
    {
        return nil;
    }
    else
    {
        return object;
    }
}

/**
 * Makes sure the object passed to it is an array. If it is, returns the object unchanged. Otherwise, wraps it in an array. If nil is passed, returns an empty array.
 *
 * Useful if you want to do a `for` loop without cluttering up with extra checks, or for dealing with crazy data sources that don't return a consistent structure every time.
 */
NSArray *TCKEnsureArray(id object)
{
    if ([object isKindOfClass:NSArray.class])
    {
        return object;
    }
    else if (object != nil)
    {
        return @[ object ];
    }
    else
    {
        return NSArray.array;
    }
}

@end
