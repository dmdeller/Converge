//
//  TCKUtilities.h
//  TCKUtilities
//
//  Created by David (work) on 7/24/14.
//  Copyright (c) 2014 TripCraft. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TCKUtilities : NSObject

id TCKNilToNull(id object);
id TCKNullToNil(id object);
NSArray *TCKEnsureArray(id object);

@end
