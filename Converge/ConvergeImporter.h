//
//  ConvergeImporter.h
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

typedef void (^ConvergeImporterSuccessBlock)(id result);
typedef void (^ConvergeImporterFailureBlock)(NSError *error);

@interface ConvergeImporter : NSObject

- (instancetype)initWithContext:(NSManagedObjectContext *)context;

- (void)importFromRecordClass:(Class)class fromFileAtPath:(NSString *)filePath success:(ConvergeImporterSuccessBlock)successBlock failure:(ConvergeImporterFailureBlock)failureBlock;

@end
