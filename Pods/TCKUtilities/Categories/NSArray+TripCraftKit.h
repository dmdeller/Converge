//
//  NSArray+TripCraftKit.h
//  TripCraftKit
//
//  Created by David Deller on 8/29/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (TripCraftKit)

- (id)firstObject_tc;

- (void)each_tc:(void (^)(id value))iterator;
- (void)eachIndex_tc:(void (^)(NSUInteger index, id value))iterator;
- (NSArray *)arrayByCollecting_tc:(id (^)(id value))iterator;
- (NSArray *)arrayWithoutRejectedValues_tc:(BOOL (^)(id value))shouldReject;
- (NSArray *)uniqueValues_tc;
- (BOOL)containsObjects_tc:(NSArray *)objects;
- (NSArray *)differenceFromArray_tc:(NSArray *)array;

@end
