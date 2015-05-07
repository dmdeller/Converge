//
//  NSLocale+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 10/3/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSLocale+TripCraftKit.h"

@implementation NSLocale (TripCraftKit)

/**
 * http://stackoverflow.com/questions/1929958/how-can-i-determine-if-iphone-is-set-for-12-hour-or-24-hour-time-display
 */
- (BOOL)uses24HourTime_tc
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:self];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24Hour = (amRange.location == NSNotFound && pmRange.location == NSNotFound);
    
    return is24Hour;
}

@end
