//
//  ConvergeClient.m
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import "ConvergeClient.h"

#import "ConvergeRecord.h"
#import "ConvergeRecord+Mapping.h"
#import "ConvergeRecord+Merging.h"

#import <TCKUtilities/TCKUtilities.h>
#import <TCKUtilities/TCKCategories.h>

@interface ConvergeClient ()

@property NSManagedObjectContext *context;
@property (nonatomic) NSManagedObjectContext *backgroundContext;
@property NSMutableDictionary *requestTimestamps;

@end

@implementation ConvergeClient

- (instancetype)initWithBaseURL:(NSURL *)url context:(NSManagedObjectContext *)context
{
    self = [super initWithBaseURL:url];
    if (self)
    {
        _context = context;
        _trackModifiedTimes = NO;
        _requestTimestamps = NSMutableDictionary.new;
        
        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    }
    return self;
}

#pragma mark -

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

- (AFHTTPRequestOperation *)fetchRecordsOfClass:(Class)recordClass parameters:(id)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure
{
    NSString *path = [recordClass collectionURLPathForHTTPMethod:@"GET" parameters:parameters];
    
    NSDate *requestStartTime = NSDate.date;
    NSString *timestampKey = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    
    // Capture value in case property changes during async blocks
    BOOL trackModifiedTimes = self.trackModifiedTimes;
    
    if (trackModifiedTimes)
    {
        NSDate *updatedAt = [self.requestTimestamps objectForKey:timestampKey];
        if (updatedAt != nil)
        {
            [self.requestSerializer setValue:[[self class] RFC2822StringForDate:updatedAt] forHTTPHeaderField:@"If-Modified-Since"];
        }
    }
    
    AFHTTPRequestOperation *operation = [self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (operation.response.statusCode == 304) // Not Modified
         {
             NSLog(@"%@: server returned 304 Not Modified for %@; no updates needed", self.class, recordClass);
             if (success != nil) success(operation, nil);
         }
         else if (responseObject != nil)
         {
             [self.backgroundContext performBlock:^
              {
                  NSError *backgroundError = nil;
                  NSArray *backgroundRecords = [recordClass mergeChangesFromProviderCollection:responseObject withQuery:parameters recursive:YES deleteStale:YES context:self.backgroundContext skipInvalidRecords:YES error:&backgroundError];
                  
                  if (backgroundRecords != nil)
                  {
                      backgroundError = nil;
                      if ([self.backgroundContext save:&backgroundError])
                      {
                          NSMutableArray *recordObjectIDs = [NSMutableArray arrayWithCapacity:backgroundRecords.count];
                          for (NSManagedObject *record in backgroundRecords)
                          {
                              [recordObjectIDs addObject:record.objectID];
                          }
                          
                          [NSOperationQueue.mainQueue addOperationWithBlock:^
                           {
                               NSError *foregroundError = nil;
                               if ([self.context save:&foregroundError])
                               {
                                   NSMutableArray *records = [NSMutableArray arrayWithCapacity:recordObjectIDs.count];
                                   for (NSManagedObjectID *recordObjectID in recordObjectIDs)
                                   {
                                       NSManagedObject *record = [self.context objectWithID:recordObjectID];
                                       [records addObject:record];
                                   }
                                   
                                   if (trackModifiedTimes)
                                   {
                                       [self.requestTimestamps setObject:requestStartTime forKey:timestampKey];
                                       [self saveRequestTimestamps];
                                   }
                                   
                                   NSLog(@"%@: wrote updates to %@ collection", self.class, recordClass);
                                   if (success != nil) success(operation, records.immutableCopy_tc);
//                                   if (changedBlock != nil) changedBlock();
                               }
                               else
                               {
                                   [self.context rollback];
                                   NSLog(@"%@ (FOREGROUND): core data error when saving %@: %@", self.class, recordClass, [foregroundError userInfo]);
                                   if (failure != nil) failure(operation, [self errorForOperation:operation error:foregroundError]);
                               }
                           }];
                      }
                      else
                      {
                          [NSOperationQueue.mainQueue addOperationWithBlock:^
                           {
                               [self.backgroundContext rollback];
                               NSLog(@"%@ (BACKGROUND): core data error when saving %@: %@", self.class, recordClass, [backgroundError userInfo]);
                               if (failure != nil) failure(operation, [self errorForOperation:operation error:backgroundError]);
                           }];
                      }
                  }
                  else
                  {
                      [NSOperationQueue.mainQueue addOperationWithBlock:^
                       {
                           [self.backgroundContext rollback];
                           NSLog(@"%@ (BACKGROUND): error when merging %@: %@", self.class, recordClass, [backgroundError userInfo]);
                           if (failure != nil) failure(operation, [self errorForOperation:operation error:backgroundError]);
                       }];
                  }
              }];
         }
         else
         {
             NSLog(@"%@: No data received in response", self.class);
             
             NSError *error = [NSError errorWithDomain:ConvergeClientErrorDomain code:ConvergeClientErrorEmptyResponse userInfo:@{ConvergeClientErrorInfoOperation: TCKNilToNull(operation)}];
             if (failure != nil) failure(operation, [self errorForOperation:operation error:error]);
         }
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (failure != nil) failure(operation, [self errorForOperation:operation error:error]);
     }];
    
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"If-Modified-Since"];
    
    return operation;
}

- (AFHTTPRequestOperation *)fetchRecord:(ConvergeRecord *)record parameters:(id)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure
{
    NSString *path = [record URLPathForHTTPMethod:@"GET" parameters:parameters];
    
    NSDate *requestStartTime = NSDate.date;
    NSString *timestampKey = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    
    // Capture value in case property changes during async blocks
    BOOL trackModifiedTimes = self.trackModifiedTimes;
    
    if (trackModifiedTimes)
    {
        NSDate *updatedAt = [self.requestTimestamps objectForKey:timestampKey];
        if (updatedAt != nil)
        {
            [self.requestSerializer setValue:[[self class] RFC2822StringForDate:updatedAt] forHTTPHeaderField:@"If-Modified-Since"];
        }
    }
    
    AFHTTPRequestOperation *operation = [self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (operation.response.statusCode == 304) // Not Modified
         {
             NSLog(@"%@: server returned 304 Not Modified for %@; no updates needed", self.class, record.class);
             if (success != nil) success(operation, nil);
         }
         else if (responseObject != nil)
         {
             NSManagedObjectID *recordObjectID = record.objectID;
             
             [self.backgroundContext performBlock:^
              {
                  ConvergeRecord *backgroundRecord = (ConvergeRecord *)[self.backgroundContext objectWithID:recordObjectID];
                  
                  NSError *backgroundError = nil;
                  if ([backgroundRecord mergeChangesFromProvider:responseObject withQuery:parameters recursive:YES error:&backgroundError])
                  {
                      backgroundError = nil;
                      if ([self.backgroundContext save:&backgroundError])
                      {
                          [NSOperationQueue.mainQueue addOperationWithBlock:^
                           {
                               NSError *foregroundError = nil;
                               if ([self.context save:&foregroundError])
                               {
                                   if (trackModifiedTimes)
                                   {
                                       [self.requestTimestamps setObject:requestStartTime forKey:timestampKey];
                                       [self saveRequestTimestamps];
                                   }
                                   
                                   NSLog(@"%@: wrote updates to %@ with id: %@", self.class, record.class, record.configuredID);
                                   if (success != nil) success(operation, record);
//                                   if (changedBlock != nil) changedBlock();
                               }
                               else
                               {
                                   [self.context rollback];
                                   NSLog(@"%@ (FOREGROUND): core data error when saving %@: %@", self.class, record.class, [foregroundError userInfo]);
                                   if (failure != nil) failure(operation, [self errorForOperation:operation error:foregroundError]);
                               }
                           }];
                      }
                      else
                      {
                          [NSOperationQueue.mainQueue addOperationWithBlock:^
                           {
                               [self.backgroundContext rollback];
                               NSLog(@"%@ (BACKGROUND): core data error when saving %@: %@", self.class, record.class, [backgroundError userInfo]);
                               if (failure != nil) failure(operation, [self errorForOperation:operation error:backgroundError]);
                           }];
                      }
                  }
                  else
                  {
                      [NSOperationQueue.mainQueue addOperationWithBlock:^
                       {
                           [self.backgroundContext rollback];
                           NSLog(@"%@ (BACKGROUND): error when merging %@: %@", self.class, record.class, [backgroundError userInfo]);
                           if (failure != nil) failure(operation, [self errorForOperation:operation error:backgroundError]);
                       }];
                  }
              }];
         }
         else
         {
             NSLog(@"%@: No data received in response", self.class);
             
             NSError *error = [NSError errorWithDomain:ConvergeClientErrorDomain code:ConvergeClientErrorEmptyResponse userInfo:@{ConvergeClientErrorInfoOperation: TCKNilToNull(operation)}];
             if (failure != nil) failure(operation, [self errorForOperation:operation error:error]);
         }
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (failure != nil) failure(operation, [self errorForOperation:operation error:error]);
     }];
    
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"If-Modified-Since"];
    
    return operation;
}

- (AFHTTPRequestOperation *)fetchRecordOfClass:(Class)recordClass withID:(id)recordID parameters:(id)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure
{
    NSString *path = [recordClass URLPathForID:recordID HTTPMethod:@"GET" parameters:parameters];
    
    NSDate *requestStartTime = NSDate.date;
    NSString *timestampKey = [[NSURL URLWithString:path relativeToURL:self.baseURL] absoluteString];
    
    // Capture value in case property changes during async blocks
    BOOL trackModifiedTimes = self.trackModifiedTimes;
    
    if (trackModifiedTimes)
    {
        NSDate *updatedAt = [self.requestTimestamps objectForKey:timestampKey];
        if (updatedAt != nil)
        {
            [self.requestSerializer setValue:[[self class] RFC2822StringForDate:updatedAt] forHTTPHeaderField:@"If-Modified-Since"];
        }
    }
    
    AFHTTPRequestOperation *operation = [self GET:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (operation.response.statusCode == 304) // Not Modified
         {
             NSLog(@"%@: server returned 304 Not Modified for %@; no updates needed", self.class, recordClass);
             if (success != nil) success(operation, nil);
         }
         else if (responseObject != nil)
         {
             [self.backgroundContext performBlock:^
              {
                  id IDAttributeName = [recordClass IDAttributeName];
                  id providerIDAttributeName = [recordClass providerIDAttributeName];
                  NSDictionary *properties = nil;
                  if (IDAttributeName != nil)
                  {
                      // Use record ID provided by server, if possible; the server may be providing us with a corrected ID in response
                      if ([responseObject isKindOfClass:NSDictionary.class] && TCKNullToNil([responseObject valueForKey:providerIDAttributeName]) != nil)
                      {
                          properties = @{IDAttributeName: [responseObject valueForKey:providerIDAttributeName]};
                      }
                      // Otherwise, use record ID originally passed into this method, if possible
                      else if ([recordClass value:recordID isCorrectClassForAttributeName:IDAttributeName inContext:self.backgroundContext])
                      {
                          properties = @{IDAttributeName: recordID};
                      }
                  }
                  
                  NSError *backgroundError = nil;
                  ConvergeRecord *backgroundRecord = [recordClass newOrExistingRecordWithProperties:properties inContext:self.backgroundContext error:&backgroundError];
                  
                  if (backgroundRecord != nil)
                  {
                      backgroundError = nil;
                      if ([backgroundRecord mergeChangesFromProvider:responseObject withQuery:parameters recursive:YES error:&backgroundError])
                      {
                          backgroundError = nil;
                          if ([self.backgroundContext save:&backgroundError])
                          {
                              NSManagedObjectID *recordObjectID = backgroundRecord.objectID;
                              
                              [NSOperationQueue.mainQueue addOperationWithBlock:^
                               {
                                   NSError *foregroundError = nil;
                                   if ([self.context save:&foregroundError])
                                   {
                                       ConvergeRecord *record = (ConvergeRecord *)[self.context objectWithID:recordObjectID];
                                       
                                       if (trackModifiedTimes)
                                       {
                                           [self.requestTimestamps setObject:requestStartTime forKey:timestampKey];
                                           [self saveRequestTimestamps];
                                       }
                                       
                                       NSLog(@"%@: wrote updates to %@ with id: %@", self.class, recordClass, recordID);
                                       if (success != nil) success(operation, record);
//                                       if (changedBlock != nil) changedBlock();
                                   }
                                   else
                                   {
                                       [self.context rollback];
                                       NSLog(@"%@ (FOREGROUND): core data error when saving %@: %@", self.class, recordClass, [foregroundError userInfo]);
                                       if (failure != nil) failure(operation, [self errorForOperation:operation error:foregroundError]);
                                   }
                               }];
                          }
                          else
                          {
                              [NSOperationQueue.mainQueue addOperationWithBlock:^
                               {
                                   [self.backgroundContext rollback];
                                   NSLog(@"%@ (BACKGROUND): core data error when saving %@: %@", self.class, recordClass, [backgroundError userInfo]);
                                   if (failure != nil) failure(operation, [self errorForOperation:operation error:backgroundError]);
                               }];
                          }
                      }
                      else
                      {
                          [NSOperationQueue.mainQueue addOperationWithBlock:^
                           {
                               [self.backgroundContext rollback];
                               NSLog(@"%@ (BACKGROUND): error when merging %@: %@", self.class, recordClass, [backgroundError userInfo]);
                               if (failure != nil) failure(operation, [self errorForOperation:operation error:backgroundError]);
                           }];
                      }
                  }
                  else
                  {
                      [NSOperationQueue.mainQueue addOperationWithBlock:^
                       {
                           [self.backgroundContext rollback];
                           NSLog(@"%@ (BACKGROUND): error when creating %@: %@", self.class, recordClass, [backgroundError userInfo]);
                           if (failure != nil) failure(operation, [self errorForOperation:operation error:backgroundError]);
                       }];
                  }
              }];
         }
         else
         {
             NSLog(@"%@: No data received in response", self.class);
             
             NSError *error = [NSError errorWithDomain:ConvergeClientErrorDomain code:ConvergeClientErrorEmptyResponse userInfo:@{ConvergeClientErrorInfoOperation: TCKNilToNull(operation)}];
             if (failure != nil) failure(operation, [self errorForOperation:operation error:error]);
         }
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (failure != nil) failure(operation, [self errorForOperation:operation error:error]);
     }];
    
    [self.requestSerializer setValue:nil forHTTPHeaderField:@"If-Modified-Since"];
    
    return operation;
}

#pragma mark -

- (AFHTTPRequestOperation *)sendNewRecord:(ConvergeRecord *)record parameters:(NSDictionary *)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure
{
    static NSString *method = @"POST";
    NSString *URLPath = [record.class collectionURLPathForHTTPMethod:method parameters:parameters];
    
    return [self sendRecord:record toURLPath:URLPath HTTPMethod:method parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)sendUpdatedRecord:(ConvergeRecord *)record parameters:(NSDictionary *)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure
{
    static NSString *method = @"PATCH";
    NSString *URLPath = [record URLPathForHTTPMethod:method parameters:parameters];
    
    return [self sendRecord:record toURLPath:URLPath HTTPMethod:method parameters:parameters success:success failure:failure];
}

- (AFHTTPRequestOperation *)sendRecord:(ConvergeRecord *)record toURLPath:(NSString *)path HTTPMethod:(NSString *)method parameters:(NSDictionary *)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure
{
    NSDictionary *recordParams = record.providerDictionary;
    if ([record.class shouldWrapRequestBody])
    {
        recordParams = @{TCKNilToNull([record.class providerClassName]): TCKNilToNull(recordParams)};
    }
    
    NSMutableDictionary *combinedParams = NSMutableDictionary.new;
    [combinedParams addEntriesFromDictionary:parameters];
    [combinedParams addEntriesFromDictionary:recordParams];
    
    AFHTTPRequestOperation *operation = [self _tc_HTTPRequestOperationWithHTTPMethod:method URLString:path parameters:combinedParams.immutableCopy_tc success:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (responseObject == nil || operation.response.statusCode == 204) // No Content
         {
             NSError *foregroundError = nil;
             if ([self.context save:&foregroundError])
             {
                 NSLog(@"%@: provider accepted sent %@; blank response, saving submitted changes", self.class, NSStringFromClass([record class]));
                 if (success != nil) success(operation, record);
             }
             else
             {
                 [self.context rollback];
                 NSLog(@"%@ (FOREGROUND): provider accepted sent %@, but saving changes to core data failed! error: %@", self.class, NSStringFromClass([record class]), [foregroundError userInfo]);
                 if (failure != nil) failure(operation, [self errorForOperation:operation error:foregroundError]);
             }
         }
         else
         {
             /**
              * NOTE: Unlike -fetchRecord: and -fetchRecordsOfClass:, this method does not use self.backgroundContext, due to how complicated it is to save records with relationships in the background.
              * -fetchRecord: and -fetchRecordsOfClass: do this by passing the NSManagedObjectID to the background context, since it is unsafe to pass NSManagedObjects directly to a different context (see Apple docs on this subject). However, this breaks in strange ways if the NSManagedObject already had related NSManagedObjects attached to it. -fetchRecord: and -fetchRecordsOfClass: get around this by not adding the relationships until after they are already running on the background thread. This is not possible with this method because the relationships are usually configured before the record is ever passed to this method.
              *
              * Since the main reason the other methods use a background context was for performance, and the performance demands are likely to be much less with this method, this is probably an acceptable compromise... for now.
              * If for some reason we ever want to send hundreds or thousands of records at a time, this may be a problem.
              */
             [self.context performBlock:^
              {
                  NSError *foregroundError = nil;
                  if ([record mergeChangesFromProvider:responseObject withQuery:parameters recursive:YES error:&foregroundError])
                  {
                      foregroundError = nil;
                      if ([self.context save:&foregroundError])
                      {
                          NSLog(@"%@: provider accepted sent %@; received & saving changes from server", self.class, NSStringFromClass([record class]));
                          if (success != nil) success(operation, record);
                      }
                      else
                      {
                          [self.context rollback];
                          NSLog(@"%@ (FOREGROUND): provider accepted sent %@, but saving changes to core data failed! error: %@", self.class, NSStringFromClass([record class]), [foregroundError userInfo]);
                          if (failure != nil) failure(operation, [self errorForOperation:operation error:foregroundError]);
                      }
                  }
                  else
                  {
                      [self.context rollback];
                      NSLog(@"%@ (FOREGROUND): error when merging %@: %@", self.class, [record class], [foregroundError userInfo]);
                      if (failure != nil) failure(operation, [self errorForOperation:operation error:foregroundError]);
                  }
              }];
         }
     }
    failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (failure != nil) failure(operation, [self errorForOperation:operation error:error]);
     }];
    
    [self.operationQueue addOperation:operation];
    
    return operation;
}

#pragma mark -

// This method copied verbatim from AFHTTPRequestOperationManager.m (only the method name changed). For some reason it isn't in the .h, so we couldn't use it directly.
- (AFHTTPRequestOperation *)_tc_HTTPRequestOperationWithHTTPMethod:(NSString *)method
                                                     URLString:(NSString *)URLString
                                                    parameters:(id)parameters
                                                       success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                                       failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:URLString relativeToURL:self.baseURL] absoluteString] parameters:parameters error:&serializationError];
    if (serializationError) {
        if (failure) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wgnu"
            dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(nil, serializationError);
            });
#pragma clang diagnostic pop
        }

        return nil;
    }

    return [self HTTPRequestOperationWithRequest:request success:success failure:failure];
}

#pragma mark -

/**
 * Subclasses can override this method if they wish for the client to return a different error in a ConvergeFailureBlock when AFNetworking encounters a failure.
 *
 * When `error` is non-nil, this method must not return nil.
 */
- (NSError *)errorForOperation:(AFHTTPRequestOperation *)operation error:(NSError *)error
{
    return error;
}

#pragma mark - Tracking Modified Times

- (NSURL *)requestTimestampsFileURL
{
    static NSString *kFilename = @"com.tripcraft.converge.request-timestamps.plist";
    
    return [[NSFileManager.defaultManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask].lastObject URLByAppendingPathComponent:kFilename];
}

- (void)loadRequestTimestamps
{
    self.requestTimestamps = [NSMutableDictionary dictionaryWithContentsOfURL:self.requestTimestampsFileURL];
    
    if (self.requestTimestamps == nil)
    {
        self.requestTimestamps = [NSMutableDictionary dictionaryWithCapacity:10];
    }
}

- (void)saveRequestTimestamps
{
    NSURL *URL = self.requestTimestampsFileURL;
    
    if (![self.requestTimestamps writeToURL:URL atomically:YES])
    {
        NSLog(@"%@: Unable to write request data to location: %@", self.class, URL);
    }
}

- (void)clearRequestTimestamps
{
    if ([NSFileManager.defaultManager fileExistsAtPath:self.requestTimestampsFileURL.path])
    {
        NSError *error = nil;
        if (![NSFileManager.defaultManager removeItemAtURL:self.requestTimestampsFileURL error:&error])
        {
            NSLog(@"%@: Unable to delete timestamps file: %@", self.class, error);
        }
    }
    
    self.requestTimestamps = NSMutableDictionary.new;
}

+ (NSString *)RFC2822StringForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"EEE, dd MMM yyyy HH:mm:ss Z";
    
    return [dateFormatter stringFromDate:date];
}

@end
