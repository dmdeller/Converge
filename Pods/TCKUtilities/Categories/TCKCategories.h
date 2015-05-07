//
//  TCKCategories.h
//  TripCraftKit
//
//  Created by David Deller on 9/26/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

// The categories are not automatically imported in TripCraftKit.h, in case you don't like them.
// You can import this header file if you want access to all the categories.

// All category methods have the unique-ish suffix _tc, which is the generally recommended pratice when writing categories in Objective-C. This avoids possible future crashes due to Apple adding methods to these classes with the same names that we chose.

#ifndef TripCraftKit_TCKCategories_h
#define TripCraftKit_TCKCategories_h

#import "NSString+TripCraftKit.h"
#import "NSMutableString+TripCraftKit.h"
#import "NSMutableAttributedString+TripCraftKit.h"
#import "NSNumber+TripCraftKit.h"
#import "NSDate+TripCraftKit.h"
#import "NSCalendar+TripCraftKit.h"
#import "NSLocale+TripCraftKit.h"
#import "NSArray+TripCraftKit.h"
#import "NSMutableArray+TripCraftKit.h"
#import "NSSet+TripCraftKit.h"
#import "NSMutableSet+TripCraftKit.h"
#import "NSOrderedSet+TripCraftKit.h"
#import "NSMutableOrderedSet+TripCraftKit.h"
#import "NSDictionary+TripCraftKit.h"
#import "NSMutableDictionary+TripCraftKit.h"

#endif
