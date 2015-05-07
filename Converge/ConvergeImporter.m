//
//  ConvergeImporter.m
//  Converge
//
//  Created by David Deller on 4/19/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import "ConvergeImporter.h"

#import "ConvergeRecord.h"
#import "ConvergeRecord+Mapping.h"
#import "ConvergeRecord+Merging.h"

@interface ConvergeImporter ()

@property NSManagedObjectContext *context;
@property (nonatomic) NSManagedObjectContext *backgroundContext;

@property (strong) NSOperationQueue *JSONOperationQueue;

@end

@implementation ConvergeImporter

- (instancetype)initWithContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self)
    {
        _context = context;
        
        _JSONOperationQueue = NSOperationQueue.new;
    }
    return self;
}

/**
 * Using a private queue context so as not to block the main thread during resource-intensive core data operations.
 * Explanation: http://developer.apple.com/library/ios/#releasenotes/DataManagement/RN-CoreData/index.html
 */
- (NSManagedObjectContext *)backgroundContext
{
    if (_backgroundContext == nil)
    {
        _backgroundContext = [NSManagedObjectContext.alloc initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        _backgroundContext.parentContext = self.context;
        _backgroundContext.undoManager = NSUndoManager.new;
    }
    
    return _backgroundContext;
}

#pragma mark -

- (void)importFromRecordClass:(Class)class fromFileAtPath:(NSString *)filePath success:(ConvergeImporterSuccessBlock)successBlock failure:(ConvergeImporterFailureBlock)failureBlock
{
    NSLog(@"%@: seeding %@ collection from file at path: %@", self.class, NSStringFromClass(class), filePath);
    
    NSError *error = nil;
    NSData *data = [NSData dataWithContentsOfFile:filePath options:0 error:&error];
    
    if (data != nil)
    {
        [self parseJSONDataInBackground:data options:0 success:^(id results)
         {
             [self.backgroundContext performBlock:^
              {
                  NSError *backgroundError = nil;
                  if ([class mergeChangesFromProviderCollection:results withQuery:nil recursive:YES deleteStale:YES context:self.backgroundContext skipInvalidRecords:NO error:&backgroundError])
                  {
                      backgroundError = nil;
                      if ([self.backgroundContext save:&backgroundError])
                      {
                          [NSOperationQueue.mainQueue addOperationWithBlock:^
                           {
                               NSError *foregroundError = nil;
                               if ([self.context save:&foregroundError])
                               {
                                   NSLog(@"%@: wrote seed data to %@ collection", self.class, NSStringFromClass(class));
                                   if (successBlock != nil) successBlock(nil);
                               }
                               else
                               {
                                   [self.context rollback];
                                   NSLog(@"%@ (FOREGROUND): core data error when saving %@ collection: %@", self.class, NSStringFromClass(class), [foregroundError userInfo]);
                                   if (failureBlock != nil) failureBlock(foregroundError);
                               }
                           }];
                      }
                      else
                      {
                          [self.backgroundContext rollback];
                          [NSOperationQueue.mainQueue addOperationWithBlock:^
                           {
                               NSLog(@"%@ (BACKGROUND): core data error when saving %@ collection: %@", self.class, NSStringFromClass(class), [backgroundError userInfo]);
                               if (failureBlock != nil) failureBlock(backgroundError);
                           }];
                      }
                  }
                  else
                  {
                      [self.backgroundContext rollback];
                      [NSOperationQueue.mainQueue addOperationWithBlock:^
                       {
                           NSLog(@"%@ (BACKGROUND): error when merging %@ collection: %@", self.class, NSStringFromClass(class), [backgroundError userInfo]);
                           if (failureBlock != nil) failureBlock(backgroundError);
                       }];
                  }
              }];
             
         }
        failure:failureBlock];
    }
    else
    {
        if (failureBlock != nil) failureBlock(error);
    }
}

#pragma mark -

/**
 * Wrapper for NSJSONSerialization +JSONObjectWithData:options:error:, which performs the parsing off the main thread so as not to block the UI.
 */
- (void)parseJSONDataInBackground:(NSData *)JSONData options:(NSJSONReadingOptions)options success:(ConvergeImporterSuccessBlock)successBlock failure:(ConvergeImporterFailureBlock)failureBlock
{
    [self.JSONOperationQueue addOperationWithBlock:^
     {
         NSError *error = nil;
         id data = [NSJSONSerialization JSONObjectWithData:JSONData options:options error:&error];
         
         if (data != nil)
         {
             [NSOperationQueue.mainQueue addOperationWithBlock:^
              {
                  if (successBlock != nil) successBlock(data);
              }];
         }
         else
         {
             NSLog(@"%@: Error parsing JSON: %@", self.class, error.userInfo);
             
             [NSOperationQueue.mainQueue addOperationWithBlock:^
              {
                  if (failureBlock != nil) failureBlock(error);
              }];
         }
     }];
}

@end
