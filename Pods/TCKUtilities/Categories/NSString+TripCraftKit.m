//
//  NSString+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 10/3/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSString+TripCraftKit.h"

#import <TransformerKit/TTTStringTransformers.h>

@implementation NSString (TripCraftKit)

- (NSString *)chompedString_tc
{
    return [self stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
}

- (BOOL)containsString_tc:(NSString *)substring
{
    if (substring.length == 0)
    {
        return YES;
    }
    else if (self.length == 0)
    {
        return NO;
    }
    else if ([self rangeOfString:substring].location == NSNotFound)
    {
        return NO;
    }
    else
    {
        return YES;
    }
}

- (BOOL)matchesRegEx:(NSString *)pattern options_tc:(NSRegularExpressionOptions)options
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
    if (regex == nil)
    {
        NSLog(@"%@: regex error: %@", self, error.userInfo);
        return NO;
    }
    
    if ([regex numberOfMatchesInString:self options:0 range:self.fullRange_tc] > 0)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

- (NSString *)stringByReplacingOccurrencesOfRegEx:(NSString *)pattern withTemplate:(NSString *)template options_tc:(NSRegularExpressionOptions)options
{
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:options error:&error];
    if (regex == nil)
    {
        NSLog(@"%@: regex error: %@", self, error.userInfo);
        return nil;
    }
    
    return [regex stringByReplacingMatchesInString:self options:0 range:self.fullRange_tc withTemplate:template];
}

- (NSRange)fullRange_tc
{
    return NSMakeRange(0, self.length);
}

- (NSNumber *)numberValue_tc
{
    NSNumberFormatter *formatter = NSNumberFormatter.new;
    
    return [formatter numberFromString:self];
}

- (NSDecimalNumber *)decimalNumberValue_tc
{
    return [NSDecimalNumber decimalNumberWithString:self];
}

/**
 * Not as smart as the Rails version - just adds an 's' to the end for plural, which is not always correct
 */
- (NSString *)pluralizedStringWithCount_tc:(NSInteger)count
{
    return [self pluralizedStringWithCount:count plural_tc:[NSString stringWithFormat:@"%@s", self]];
}

- (NSString *)pluralizedStringWithCount:(NSInteger)count plural_tc:(NSString *)plural
{
    if (count == 1)
    {
        return self;
    }
    else
    {
        return plural;
    }
}

#pragma mark - TransformerKit

// For examples, see: https://github.com/mattt/TransformerKit

- (NSString *)snakeCasedString_tc
{
    return [[NSValueTransformer valueTransformerForName:TTTSnakeCaseStringTransformerName] transformedValue:self];
}

- (NSString *)unSnakeCasedString_tc
{
    return [[NSValueTransformer valueTransformerForName:TTTSnakeCaseStringTransformerName] reverseTransformedValue:self];
}

/**
 * Note: This meaning of llamaCase is what most people think of as CamelCase
 */
- (NSString *)llamaCasedString_tc
{
    return [[NSValueTransformer valueTransformerForName:TTTLlamaCaseStringTransformerName] transformedValue:self];
}

- (NSString *)unLlamaCasedString_tc
{
    return [[NSValueTransformer valueTransformerForName:TTTLlamaCaseStringTransformerName] reverseTransformedValue:self];
}

- (NSString *)camelCasedString_tc
{
    return [[NSValueTransformer valueTransformerForName:TTTCamelCaseStringTransformerName] transformedValue:self];
}

- (NSString *)unCamelCasedString_tc
{
    return [[NSValueTransformer valueTransformerForName:TTTCamelCaseStringTransformerName] transformedValue:self];
}

- (NSString *)trainCasedString_tc
{
    return [[NSValueTransformer valueTransformerForName:TTTTrainCaseStringTransformerName] transformedValue:self];
}

- (NSString *)unTrainCasedString_tc
{
    return [[NSValueTransformer valueTransformerForName:TTTTrainCaseStringTransformerName] transformedValue:self];
}

@end
