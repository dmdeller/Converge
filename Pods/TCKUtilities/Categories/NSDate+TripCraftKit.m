//
//  NSDate+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 10/3/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSDate+TripCraftKit.h"

#import "NSCalendar+TripCraftKit.h"

@implementation NSDate (TripCraftKit)

+ (NSDate *)dateFromString:(NSString *)dateString withFormat_tc:(NSString *)format
{
    if (dateString == nil)
    {
        return nil;
    }
    
    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateFormat = format;
    
    // Using getObjectValue:forString:range:error: instead of dateFromString: because the latter mysteriously fails on time zones of the format +00:00, which just so happens to be the format that Ruby likes to output.
    // See: http://stackoverflow.com/questions/3094819/nsdateformatter-returning-nil-in-os-4-0
    NSDate *date = nil;
    [formatter getObjectValue:&date forString:dateString range:nil error:nil];
    
    return date;
}

- (NSString *)stringValueWithFormat:(NSString *)format inTimeZone_tc:(NSTimeZone *)timeZone
{
    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateFormat = format;
    formatter.timeZone = timeZone;
    
    return [formatter stringFromDate:self];
}

- (NSString *)stringValueWithDateStyle:(NSDateFormatterStyle)dateStyle andTimeStyle:(NSDateFormatterStyle)timeStyle inTimeZone_tc:(NSTimeZone *)timeZone
{
    NSDateFormatter *formatter = NSDateFormatter.new;
    formatter.dateStyle = dateStyle;
    formatter.timeStyle = timeStyle;
    formatter.timeZone = timeZone;
    
    return [formatter stringFromDate:self];
}

/**
 * Lops off the 'time' part of an NSDate, returning the same date, only at the beginning of the day at midnight.
 */
- (NSDate *)startOfDayInTimeZone_tc:(NSTimeZone *)timeZone
{
    NSCalendar *calendar = [NSCalendar calendarForTimeZone_tc:timeZone];
    NSDateComponents *todayComponents = [calendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:self];
    
    return [calendar dateFromComponents:todayComponents];
}

@end
