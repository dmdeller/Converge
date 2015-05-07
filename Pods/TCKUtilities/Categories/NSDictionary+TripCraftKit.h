//
//  NSDictionary+TripCraftKit.h
//  TripCraftKit
//
//  Created by David Deller on 8/29/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (TripCraftKit)

- (void)each_tc:(void (^)(id key, id value))iterate;
- (id)objectAtPath_tc:(id)path;
- (NSDictionary *)dictionaryWithInvertedKeysAndValues_tc;
- (BOOL)hasKeys_tc:(NSArray *)keys;

@end
