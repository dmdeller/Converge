//
//  NSMutableDictionary+TripCraftKit.h
//  TripCraftKit
//
//  Created by David Deller on 9/26/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableDictionary (TripCraftKit)

- (NSDictionary *)immutableCopy_tc;
- (void)removeObject_tc:(id)object;

@end
