//
//  NSDate+TripCraftKit.h
//  TripCraftKit
//
//  Created by David Deller on 10/3/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (TripCraftKit)

+ (NSDate *)dateFromString:(NSString *)dateString withFormat_tc:(NSString *)format;

- (NSString *)stringValueWithFormat:(NSString *)format inTimeZone_tc:(NSTimeZone *)timeZone;
- (NSString *)stringValueWithDateStyle:(NSDateFormatterStyle)dateStyle andTimeStyle:(NSDateFormatterStyle)timeStyle inTimeZone_tc:(NSTimeZone *)timeZone;

- (NSDate *)startOfDayInTimeZone_tc:(NSTimeZone *)timeZone;

@end
