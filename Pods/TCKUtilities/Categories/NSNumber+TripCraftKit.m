//
//  NSNumber+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 10/3/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSNumber+TripCraftKit.h"

@implementation NSNumber (TripCraftKit)

- (NSString *)stringValueWithStyle:(NSNumberFormatterStyle)style locale_tc:(NSLocale *)locale
{
    NSNumberFormatter *formatter = NSNumberFormatter.new;
    formatter.locale = locale;
    formatter.numberStyle = style;
    
    return [formatter stringFromNumber:self];
}

@end
