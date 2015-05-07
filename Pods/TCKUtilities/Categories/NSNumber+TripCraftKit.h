//
//  NSNumber+TripCraftKit.h
//  TripCraftKit
//
//  Created by David Deller on 10/3/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (TripCraftKit)

- (NSString *)stringValueWithStyle:(NSNumberFormatterStyle)style locale_tc:(NSLocale *)locale;

@end
