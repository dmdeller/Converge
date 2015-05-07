//
//  NSDictionary+TripCraftKit.m
//  TripCraftKit
//
//  Created by David Deller on 8/29/12.
//  Copyright (c) 2012 TripCraft. All rights reserved.
//

#import "NSDictionary+TripCraftKit.h"

#import "NSArray+TripCraftKit.h"
#import "NSMutableDictionary+TripCraftKit.h"
#import "TCKUtilities.h"

@implementation NSDictionary (TripCraftKit)

- (void)each_tc:(void (^)(id key, id value))iterate
{
    for (id key in self)
    {
        id value = [self objectForKey:key];
        
        iterate(key, value);
    }
}

/**
 * Allows traversing a multi-dimensional dictionary with one call, without worrying about crashing because one of the dimensions in the middle is nil
 */
- (id)objectAtPath_tc:(id)path
{
    NSArray *pathComponents = TCKEnsureArray(path);
    NSDictionary *previousDictionary = self;
    NSString *lastComponent = pathComponents.lastObject;
    
    for (NSString *component in pathComponents)
    {
        id currentObject = [previousDictionary objectForKey:component];
        
        if (component == lastComponent)
        {
            return currentObject;
        }
        else
        {
            if (![currentObject isKindOfClass:NSDictionary.class])
            {
                return nil;
            }
            
            previousDictionary = currentObject;
        }
    }
    
    return nil;
}

- (NSDictionary *)dictionaryWithInvertedKeysAndValues_tc
{
    NSMutableDictionary *newDict = [NSMutableDictionary dictionaryWithCapacity:self.count];
    
    [self each_tc:^(id key, id value)
     {
         newDict[value] = key;
     }];
    
    return newDict.immutableCopy_tc;
}

- (BOOL)hasKeys_tc:(NSArray *)keys
{
    return [self.allKeys containsObjects_tc:keys];
}

@end
