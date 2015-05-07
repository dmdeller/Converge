//
//  NSMutableString+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 10/4/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSMutableString+TripCraftKit.h"

@implementation NSMutableString (TripCraftKit)

- (NSString *)immutableCopy_tc
{
    return [NSString stringWithString:self];
}

@end
