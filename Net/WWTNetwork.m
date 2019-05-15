//
//  WWTNetwork.m
//  WWTKit
//
//  Created by eamon on 2019/4/1.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import "WWTNetwork.h"

#import <AFNetworking/AFNetworking.h>



//------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------

//MARK: >> Scheme
//------------------------------------------------------------------------

WWTNetworkRequestURLScheme WWTNetworkRequestURLScheme_HTTP  = @"http";
WWTNetworkRequestURLScheme WWTNetworkRequestURLScheme_HTTPS = @"https";

//MARK: >> Method
//------------------------------------------------------------------------

WWTNetworkRequestMethod WWTNetworkRequestMethod_GET    = @"GET";
WWTNetworkRequestMethod WWTNetworkRequestMethod_POST   = @"POST";
WWTNetworkRequestMethod WWTNetworkRequestMethod_PUT    = @"PUT";
WWTNetworkRequestMethod WWTNetworkRequestMethod_DELETE = @"DELETE";
WWTNetworkRequestMethod WWTNetworkRequestMethod_PATCH  = @"PATCH";



//---------------------------------------------------------------------------------------------------
#pragma mark - Interface (WWTNetwork)
//---------------------------------------------------------------------------------------------------

@interface WWTNetwork ()

@property (strong, nonatomic) AFURLSessionManager*  sessionManager;
@property (strong, nonatomic) dispatch_queue_t      sessionCompleteGCDQueue;

@end


//------------------------------------------------------------------------
#pragma mark - Implementation (WWTNetwork)
//------------------------------------------------------------------------

@implementation WWTNetwork


//------------------------------------------------------------------------
#pragma mark - Initialize
//------------------------------------------------------------------------
+ (instancetype)defaultNetwork
{
    static WWTNetwork *_network;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        dispatch_queue_t queue = dispatch_queue_create("com.wewave.wwtkit.network.queue", NULL);
        _network = [[WWTNetwork alloc] initWithSessionConfig:config completionQueue:queue];
    });
    return _network;
}

- (instancetype)initWithSessionConfig:(NSURLSessionConfiguration *)config
                      completionQueue:(dispatch_queue_t)queue
{
    if (self = [super init]) {
        
        NSURLSessionConfiguration *init_cfg = nil;
        if (!config) {
            init_cfg = [NSURLSessionConfiguration defaultSessionConfiguration];
        } else {
            init_cfg = config;
        }
        
        AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:init_cfg];
        if (queue) {
            manager.completionQueue = queue;
        }
        
        self.sessionManager  = manager;
        self.sessionCompleteGCDQueue = queue;
    }
    return self;
}

//------------------------------------------------------------------------
#pragma mark - Public Methods
//------------------------------------------------------------------------

//MARK: >> Data Request
//------------------------------------------------------------------------

/**
 异步请求网络
 
 @param request 网络请求对象
 @param complete 请求完成回调
 */
- (void)asyncDataTaskWithRequest:(NSURLRequest *)request
                        complete:(WWTNetworkResponseBlock)complete
{
    NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (complete) {
            complete(response, responseObject, error);
        }
    }];
    
    [task resume];
}

- (BOOL)syncDataTaskWithRequest:(NSURLRequest *)request
                       response:(NSURLResponse *__autoreleasing *)response
                    responseObj:(__autoreleasing id *)obj
                    responseErr:(NSError *__autoreleasing *)error
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    __block NSURLResponse *task_response = nil;
    __block id             task_obj      = nil;
    __block NSError       *task_error    = nil;
    
    NSURLSessionDataTask *task = [self.sessionManager dataTaskWithRequest:request uploadProgress:nil downloadProgress:nil completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        
        task_response = response;
        task_obj      = responseObject;
        task_error    = error;
        
        
        dispatch_group_leave(group);
    }];
    
    // >> go
    [task resume];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    *response = task_response;
    *obj      = task_obj;
    *error    = task_error;
    
    
    if (!task_error) {
        return YES;
    }
    
    return NO;
}

//MARK: >> Upload Task
//---------------------------------------------------------------------------------------------------
- (void)asyncUploadTaskWithRequest:(NSURLRequest *)request
                          progress:(WWTNetworkProgressBlock)progress
                          complete:(WWTNetworkResponseBlock)complete
{
    NSURLSessionUploadTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (progress) {
            progress(uploadProgress.fractionCompleted);
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        if (complete) {
            complete(response, responseObject, error);
        }
    }];
    
    // >> go
    [task resume];
}

- (BOOL)syncUploadTaskWithRequest:(NSURLRequest *)request
                         response:(NSURLResponse *__autoreleasing *)response
                      responseObj:(__autoreleasing id *)obj
                      responseErr:(NSError *__autoreleasing *)error
                         progress:(WWTNetworkProgressBlock)prog_block
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    __block NSURLResponse *task_response = nil;
    __block id             task_obj      = nil;
    __block NSError       *task_error    = nil;
    
    NSURLSessionUploadTask *task = [self.sessionManager uploadTaskWithStreamedRequest:request progress:^(NSProgress * _Nonnull uploadProgress) {
        
        if (prog_block) {
            prog_block(uploadProgress.fractionCompleted);
        }
        
    } completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
        
        task_response = response;
        task_obj      = responseObject;
        task_error    = error;
        
        
        dispatch_group_leave(group);
    }];
    
    // >> go
    [task resume];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    *response = task_response;
    *obj      = task_obj;
    *error    = task_error;
    
    if (!task_error) {
        return YES;
    }
    
    return NO;
}

//MARK: >> Download Task
//------------------------------------------------------------------------

- (void)asyncDownloadTaskWithRequest:(NSURLRequest *)request
                            progress:(WWTNetworkProgressBlock)progress
                         destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                            complete:(WWTNetworkDownloadResponseBlock)complete
{
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (progress) {
            progress(downloadProgress.fractionCompleted);
        }
        
    } destination:destination completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        if (complete) {
            complete(response, filePath, error);
        }
    }];
    
    // >> go
    [task resume];
}

- (BOOL)syncDownloadTaskWithRequest:(NSURLRequest *)request
                             toPath:(NSString *)toPath
                           response:(NSURLResponse *__autoreleasing *)response
                   responseFilePath:(NSURL *__autoreleasing *)path
                        responseErr:(NSError *__autoreleasing *)error
                           progress:(WWTNetworkProgressBlock)prog_block
{
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    __block NSURLResponse *task_response = nil;
    __block NSURL          *task_path    = nil;
    __block NSError       *task_error    = nil;
    
    NSURLSessionDownloadTask *task = [self.sessionManager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
        
        if (prog_block) {
            prog_block(downloadProgress.fractionCompleted);
        }
        
    } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
        
        return [NSURL fileURLWithPath:toPath];
        
    } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
        
        task_response = response;
        task_path     = filePath;
        task_error    = error;
        
        dispatch_group_leave(group);
    }];
    
    // >> go
    [task resume];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
    
    *response = task_response;
    *path     = task_path;
    *error    = task_error;
    
    if (!task_error) {
        return YES;
    }
    
    return NO;
}

//MARK: >> Controls
//------------------------------------------------------------------------

- (NSArray<NSURLRequest*> *)tasks
{
    __block NSMutableArray *requests = [@[] mutableCopy];
    
    [self.sessionManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSURLRequest *request = task.currentRequest;
        [requests addObject:request];
    }];
    
    return requests;
}

- (void)cancelTaskByRequest:(NSURLRequest *)request
{
    [self.sessionManager.tasks enumerateObjectsUsingBlock:^(NSURLSessionTask *task, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([request.URL.absoluteString isEqualToString:task.currentRequest.URL.absoluteString]) {
            [task cancel];
            *stop = YES;
        }
    }];
}

- (void)cancelAllTasks
{
    [self.sessionManager.tasks makeObjectsPerformSelector:@selector(cancel)];
}


@end
