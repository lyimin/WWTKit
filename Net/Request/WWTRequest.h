//
//  WWTRequest.h
//  WWTKit
//
//  Created by eamon on 2019/4/2.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WWTNetwork;



//------------------------------------------------------------------------
#pragma mark - <WWTRequesting>
//------------------------------------------------------------------------

@protocol WWTRequesting <NSObject>
@optional

/**
 请求方法, 默认GET, WWTNetworkRequestMethod
 
 @return NSString
 */
- (NSString *)requestHTTPMethod;


/**
 服务器http协议, 默认https, WWTNetworkRequestURLScheme
 
 @return NSString
 */
- (NSString *)requestHTTPScheme;


/**
 服务器地址 (BaseURL) 如: https://wewave.com.cn
 
 @return NSString
 */
- (NSString *)requestHTTPDomain;


/**
 请求路径
 
 @return NSString
 */
- (NSString *)requestHTTPPath;


/**
 是否使用HTTP DNS, 默认YES
 
 @return BOOL
 */
- (BOOL)requestHTTPDNS;


/**
 增量Body内容, 用于附加到接口Parameter上
 
 @return NSDictionary
 */
- (NSDictionary *)requestIncreParameter;


/**
 请求Cookies 会在请求前添加到Cookie Store
 
 @return array<NSHTTPCookie>
 */
- (NSArray *)requestCookies;


/**
 请求头
 
 @return NSDictionary
 */
- (NSDictionary *)requestHeaders;


/**
 错误码
 
 @return NSString
 */
- (NSString *)errorCodeFromRequest;


/**
 错误描述
 
 @return NSString
 */
- (NSString *)errorMsgFromRequest;


/**
 请求超时阀值
 
 @return NSTimeInterval
 */
- (NSTimeInterval)requestTimeoutInterval;


/**
 请求容器. 默认使用 [WWTNetwork sharedNetwork]
 
 @return MLNetwork
 */
- (WWTNetwork *)requestNetwork;


/**
 请求的缓存策略. 默认使用 NSURLRequestUseProtocolCachePolicy
 
 @return NSURLRequestCachePolicy
 */
- (NSURLRequestCachePolicy)requestCachePolicy;


/**
 自定义请求实现
 
 @return NSString
 */
- (NSMutableURLRequest *)customRequestWithRequest:(NSMutableURLRequest *)request;


@end



//------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------

//MARK: >> Error Domain
//------------------------------------------------------------------------
typedef NSString * const WWTRequestErrorDomain;

extern WWTRequestErrorDomain WWTRequestErrorDomain_Request;
extern WWTRequestErrorDomain WWTRequestErrorDomain_Method;
extern WWTRequestErrorDomain WWTRequestErrorDomain_URL;
extern WWTRequestErrorDomain WWTRequestErrorDomain_DNS;
extern WWTRequestErrorDomain WWTRequestErrorDomain_HostIPMapping;


//MARK: >> Error Info Key
//------------------------------------------------------------------------
typedef NSString * const WWTRequestErrorInfoKey;

extern WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Domain;
extern WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Class;
extern WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Code;
extern WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Msg;
extern WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Response;


//------------------------------------------------------------------------
#pragma mark - Interface (WWTRequest)
//------------------------------------------------------------------------

@interface WWTRequest : NSObject <WWTRequesting>

//MARK: >> 请求信息
//------------------------------------------------------------------------

@property (copy,   nonatomic, readonly) NSString*       method;
@property (copy,   nonatomic, readonly) NSString*       baseURL;
@property (copy,   nonatomic, readonly) NSString*       fullURL;

@property (strong, nonatomic) NSURLRequest* request;
@property (strong, nonatomic) NSDictionary* parameter;
@property (strong, nonatomic) NSError*      requestErr;


//MARK: >> 响应信息
//------------------------------------------------------------------------

@property (strong, nonatomic) NSHTTPURLResponse*  response;
@property (copy,   nonatomic) id                  responseObj;



/**
 异步请求
 
 @param complete block, not in main thread
 */
- (void)async:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete;

/**
 同步请求
 
 @param error NSError
 @return id Result
 */
- (id)dataAfterSync:(NSError *__autoreleasing *)error;


@end
