//
//  NSCalendar+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 10/3/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSCalendar+TripCraftKit.h"

@implementation NSCalendar (TripCraftKit)

+ (NSCalendar *)calendarForTimeZone_tc:(NSTimeZone *)timeZone
{
    NSCalendar *calendar = [NSCalendar.alloc initWithCalendarIdentifier:NSGregorianCalendar];
    calendar.timeZone = timeZone;
    
    return calendar;
}

@end
