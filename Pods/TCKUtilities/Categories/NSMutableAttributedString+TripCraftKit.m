//
//  NSMutableAttributedString+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 10/4/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSMutableAttributedString+TripCraftKit.h"

@implementation NSMutableAttributedString (TripCraftKit)

- (NSAttributedString *)immutableCopy_tc
{
    return [NSAttributedString.alloc initWithAttributedString:self.copy];
}

@end
