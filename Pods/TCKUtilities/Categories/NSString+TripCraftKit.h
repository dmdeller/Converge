//
//  NSString+TripCraftKit.h
//  TripCraftKit
//
//  Created by David Deller on 10/3/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TripCraftKit)

- (NSString *)chompedString_tc;
- (BOOL)containsString_tc:(NSString *)substring;
- (BOOL)matchesRegEx:(NSString *)pattern options_tc:(NSRegularExpressionOptions)options;
- (NSString *)stringByReplacingOccurrencesOfRegEx:(NSString *)pattern withTemplate:(NSString *)template options_tc:(NSRegularExpressionOptions)options;
- (NSRange)fullRange_tc;
- (NSNumber *)numberValue_tc;
- (NSDecimalNumber *)decimalNumberValue_tc;
- (NSString *)pluralizedStringWithCount_tc:(NSInteger)count;
- (NSString *)pluralizedStringWithCount:(NSInteger)count plural_tc:(NSString *)plural;

- (NSString *)snakeCasedString_tc;
- (NSString *)unSnakeCasedString_tc;
- (NSString *)llamaCasedString_tc;
- (NSString *)unLlamaCasedString_tc;
- (NSString *)camelCasedString_tc;
- (NSString *)unCamelCasedString_tc;
- (NSString *)trainCasedString_tc;
- (NSString *)unTrainCasedString_tc;

@end
