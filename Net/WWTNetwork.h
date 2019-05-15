//
//  WWTNetwork.h
//  WWTKit
//
//  Created by eamon on 2019/4/1.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



//------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------

//MARK: >> Scheme
//------------------------------------------------------------------------

typedef NSString * const WWTNetworkRequestURLScheme;

extern WWTNetworkRequestURLScheme WWTNetworkRequestURLScheme_HTTP;
extern WWTNetworkRequestURLScheme WWTNetworkRequestURLScheme_HTTPS;

//MARK: >> Method
//------------------------------------------------------------------------

typedef NSString * const WWTNetworkRequestMethod;

extern WWTNetworkRequestMethod WWTNetworkRequestMethod_GET;
extern WWTNetworkRequestMethod WWTNetworkRequestMethod_POST;
extern WWTNetworkRequestMethod WWTNetworkRequestMethod_PUT;
extern WWTNetworkRequestMethod WWTNetworkRequestMethod_DELETE;
extern WWTNetworkRequestMethod WWTNetworkRequestMethod_PATCH;

//MARK: >> Response
//------------------------------------------------------------------------

/// 请求完成Block
typedef void(^WWTNetworkResponseBlock)(NSURLResponse *response, id responseObject, NSError *error);

/// 下载完成Block
typedef void(^WWTNetworkDownloadResponseBlock)(NSURLResponse *response, NSURL *filePath, NSError *error);

/// 请求进度Block
typedef void(^WWTNetworkProgressBlock)(float progress);



//------------------------------------------------------------------------
#pragma mark - Interface (WWTNetwork)
//------------------------------------------------------------------------

@interface WWTNetwork : NSObject


//------------------------------------------------------------------------
#pragma mark - Initialize
//------------------------------------------------------------------------
+ (instancetype)defaultNetwork;

/**
 初始化Network

 @param config 网络请求配置项
 @param queue 队列
 @return Network实例
 */
- (instancetype)initWithSessionConfig:(NSURLSessionConfiguration *)config
                      completionQueue:(dispatch_queue_t)queue;


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
                        complete:(WWTNetworkResponseBlock)complete;

/**
 同步请求网络

 @param request 网络请求对象
 @param response 请求返回对象
 @param obj 返回数据集
 @param error 错误
 @return 是否请求成功
 */
- (BOOL)syncDataTaskWithRequest:(NSURLRequest *)request
                       response:(NSURLResponse *__autoreleasing *)response
                    responseObj:(__autoreleasing id *)obj
                    responseErr:(NSError *__autoreleasing *)error;


//MARK: >> Upload Task
//------------------------------------------------------------------------

/**
 异步上传数据

 @param request 网络请求对象
 @param progress 上传进度
 @param complete 上传完成回调
 */
- (void)asyncUploadTaskWithRequest:(NSURLRequest *)request
                          progress:(WWTNetworkProgressBlock)progress
                          complete:(WWTNetworkResponseBlock)complete;

/**
 同步上传数据

 @param request 网络请求对象
 @param response 请求返回对象
 @param obj 返回数据集
 @param error 错误处理
 @param progress 上传进度
 @return 是否上传成功
 */
- (BOOL)syncUploadTaskWithRequest:(NSURLRequest *)request
                         response:(NSURLResponse *__autoreleasing *)response
                      responseObj:(__autoreleasing id *)obj
                      responseErr:(NSError *__autoreleasing *)error
                         progress:(WWTNetworkProgressBlock)progress;


//MARK: >> Download Task
//------------------------------------------------------------------------

/**
 异步下载资源

 @param request 网络请求对象
 @param progress 下载进度
 @param destination 下载目的地
 @param complete 回调
 */
- (void)asyncDownloadTaskWithRequest:(NSURLRequest *)request
                            progress:(void (^)(float progs))progress
                         destination:(NSURL * (^)(NSURL *targetPath, NSURLResponse *response))destination
                            complete:(WWTNetworkDownloadResponseBlock)complete;

/**
 同步下载资源

 @param request 网络请求对象
 @param toPath 文件名
 @param response 请求返回对象
 @param path 资源下载的目录
 @param error 错误处理
 @param progress 下载进度
 @return 是否下载成功
 */
- (BOOL)syncDownloadTaskWithRequest:(NSURLRequest *)request
                             toPath:(NSString *)toPath
                           response:(NSURLResponse *__autoreleasing *)response
                   responseFilePath:(NSURL *__autoreleasing *)path
                        responseErr:(NSError *__autoreleasing *)error
                           progress:(WWTNetworkProgressBlock)progress;


//MARK: >> Event
//------------------------------------------------------------------------

/**
 返回当前进行所有Task
 */
- (NSArray<NSURLRequest*> *)tasks;

/**
 取消某个Task
 */
- (void)cancelTaskByRequest:(NSURLRequest *)request;

/**
 取消所有Task
 */
- (void)cancelAllTasks;


@end
