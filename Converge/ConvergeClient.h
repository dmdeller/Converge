//
//  ConvergeClient.h
//  Converge
//
//  Created by David Deller on 3/2/15.
//  Copyright (c) 2015 TripCraft LLC. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>

@class ConvergeRecord;

typedef void (^ConvergeSuccessBlock)(AFHTTPRequestOperation *operation, id response);
typedef void (^ConvergeFailureBlock)(AFHTTPRequestOperation *operation, NSError *error);

static NSString *const ConvergeClientErrorDomain = @"com.tripcraft.converge.client.error";
static NSString *const ConvergeClientErrorInfoOperation = @"com.tripcraft.converge.client.error.operation";

typedef enum
{
    ConvergeClientErrorEmptyResponse,
} ConvergeClientError;

@interface ConvergeClient : AFHTTPRequestOperationManager

@property (readonly) NSManagedObjectContext *context;
@property BOOL trackModifiedTimes;

- (instancetype)initWithBaseURL:(NSURL *)url context:(NSManagedObjectContext *)context;

- (AFHTTPRequestOperation *)fetchRecordsOfClass:(Class)class parameters:(id)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;
- (AFHTTPRequestOperation *)fetchRecord:(ConvergeRecord *)record parameters:(id)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;
- (AFHTTPRequestOperation *)fetchRecordOfClass:(Class)recordClass withID:(id)recordID parameters:(id)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;

- (AFHTTPRequestOperation *)sendNewRecord:(ConvergeRecord *)record parameters:(NSDictionary *)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;
- (AFHTTPRequestOperation *)sendUpdatedRecord:(ConvergeRecord *)record parameters:(NSDictionary *)parameters success:(ConvergeSuccessBlock)success failure:(ConvergeFailureBlock)failure;

- (NSURL *)requestTimestampsFileURL;

@end
