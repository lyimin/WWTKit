//
//  WWTRequest.m
//  WWTKit
//
//  Created by eamon on 2019/4/2.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import "WWTRequest.h"

#import "AFNetworking.h"

#import "WWTNetwork.h"
#import "WWTDevice.h"

#import "NSDictionary+WWTHelper.h"


//------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------

//MARK: >> Error Domain
//------------------------------------------------------------------------
WWTRequestErrorDomain WWTRequestErrorDomain_Request        = @"com.wewave.wwtkit.request.err.domain.request";
WWTRequestErrorDomain WWTRequestErrorDomain_Method         = @"com.wewave.wwtkit.request.err.domain.method";
WWTRequestErrorDomain WWTRequestErrorDomain_URL            = @"com.wewave.wwtkit.request.err.domain.url";
WWTRequestErrorDomain WWTRequestErrorDomain_DNS            = @"com.wewave.wwtkit.request.err.domain.dns";
WWTRequestErrorDomain WWTRequestErrorDomain_HostIPMapping  = @"com.wewave.wwtkit.request.err.domain.hostIPMapping";

//MARK: >> Error Info Key
//------------------------------------------------------------------------
WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Class    = @"com.wewave.wwtkit.request.err.info.info.class";
WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Domain   = @"com.wewave.wwtkit.request.err.info.info.domain";
WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Code     = @"com.wewave.wwtkit.request.err.info.info.code";
WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Msg      = @"com.wewave.wwtkit.request.err.info.info.msg";
WWTRequestErrorInfoKey WWTRequestErrorInfoKey_Response = @"com.wewave.wwtkit.request.err.info.info.resp";


//------------------------------------------------------------------------
#pragma mark - Interface (WWTRequest)
//------------------------------------------------------------------------

@interface WWTRequest () 

@property (strong, nonatomic) NSError* responseErr;

@end

//------------------------------------------------------------------------
#pragma mark - Implementation (WWTRequest)
//------------------------------------------------------------------------

@implementation WWTRequest


//------------------------------------------------------------------------
#pragma mark - Base Methods
//------------------------------------------------------------------------

- (NSString *)requestBaseURL
{
    NSString *scheme = [self requestHTTPScheme];
    if (!scheme) {
        return nil;
    }
    
    NSString *domain = [self requestHTTPDomain];
    if (!domain) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%@://%@", scheme, domain];
}

- (NSString *)requestFullURL
{
    NSString *baseURL = [self requestBaseURL];
    if (!baseURL) {
        return nil;
    }
    
    NSString *path = [self requestHTTPPath];
    if (path) {
        return [baseURL stringByAppendingString:path];
    }
    else {
        return baseURL;
    }
}

- (NSString *)fixURL:(NSString *)url
{
    if (!url) {
        return nil;
    }
    return [url stringByReplacingOccurrencesOfString:@"%5B%5D=" withString:@"="];
}

//------------------------------------------------------------------------
#pragma mark - Request Methods
//------------------------------------------------------------------------

- (NSMutableURLRequest *)request:(NSString *)url error:(NSError *__autoreleasing *)error
{
    if (!url) {
        if (error) {
            *error = [NSError errorWithDomain:WWTRequestErrorDomain_URL code:0 userInfo:nil];
        }
        return nil;
    }
    
    NSString *method = [self requestHTTPMethod];
    if (!method) {
        if (error) {
            *error = [NSError errorWithDomain:WWTRequestErrorDomain_Method code:0 userInfo:nil];
        }
        return nil;
    }
    
    NSError *net_error = nil;
    AFJSONRequestSerializer *requestSerializer  = [AFJSONRequestSerializer serializer];
    
    // parameter
    NSDictionary *incre_parameter  = [self requestIncreParameter];
    NSDictionary *custom_parameter = self.parameter;
    
    NSMutableDictionary *parameter = [@{} mutableCopy];
    if (!incre_parameter && !custom_parameter) {
        parameter = nil;
    }
    if (incre_parameter) {
        [parameter addEntriesFromDictionary:incre_parameter];
    }
    if (custom_parameter) {
        [parameter addEntriesFromDictionary:custom_parameter];
    }
    
    // header
    NSDictionary *preset_headers = @{};
    NSDictionary *custom_headers = [self requestHeaders];
    if (preset_headers) {
        for (NSString *field in preset_headers.allKeys) {
            [requestSerializer setValue:preset_headers[field] forHTTPHeaderField:field];
        }
    }
    if (custom_headers) {
        for (NSString *field in custom_headers.allKeys) {
            [requestSerializer setValue:custom_headers[field] forHTTPHeaderField:field];
        }
    }
    
    // cookie
    NSArray *cookies = [self requestCookies];
    if (cookies) {
        for (NSHTTPCookie *cookie in cookies) {
            [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
        }
    }
    
    // request
    NSMutableURLRequest *request =
    [requestSerializer requestWithMethod:method URLString:url parameters:parameter error:&net_error];
    if (net_error) {
        if (error) {
            *error = [NSError errorWithDomain:WWTRequestErrorDomain_Request
                                         code:net_error.code
                                     userInfo:net_error.userInfo];
        }
        return nil;
    }
    
    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    [request setValue:timestamp   forHTTPHeaderField:@"WWT-Timestamp"];
    
    NSMutableURLRequest *customReq = [self customRequestWithRequest:request];
    if (customReq && [customReq isKindOfClass:[NSMutableURLRequest class]]) {
        request = customReq;
    }
    
    // 设置cache策略
    request.cachePolicy = [self RequestCachePolicy];
    
    // 修正afnet对URL转义的差异
    if ([method isEqualToString:WWTNetworkRequestMethod_GET]) {
        NSString *fix_url = [self fixURL:request.URL.absoluteString];
        request.URL = [NSURL URLWithString:fix_url];
    }
    
    // timeout
    request.timeoutInterval = [self requestTimeoutInterval];
    
    // result
    return request;
}


- (NSMutableURLRequest *)requestAfterSync:(NSError *__autoreleasing *)error
{
    NSString *domain = [self requestHTTPDomain];
    if (!domain) {
        if (error) {
            *error = [NSError errorWithDomain:WWTRequestErrorDomain_URL code:0 userInfo:nil];
        }
        return nil;
    }
    
    NSString *scheme = [self requestHTTPScheme];
    if (!scheme) {
        if (error) {
            *error = [NSError errorWithDomain:WWTRequestErrorDomain_URL code:0 userInfo:nil];
        }
        return nil;
    }
    
    NSString *url = nil;
    if ([self requestHTTPDNS]) {
        url = [NSString stringWithFormat:@"%@://%@", scheme, domain];
    }
    else {
        url = [NSString stringWithFormat:@"%@://%@", scheme, domain];
    }
    
    NSString *path = [self requestHTTPPath];
    if (path) {
        url = [url stringByAppendingString:path];
    }
    
    return [self request:url error:error];
}

- (void)requestAfterAsync:(void(^)(NSMutableURLRequest *request, NSError *error))complete
{
    NSString *domain = [self requestHTTPDomain];
    if (!domain) {
        if (complete) {
            complete(nil, [NSError errorWithDomain:WWTRequestErrorDomain_URL code:0 userInfo:nil]);
        }
        return;
    }
    
    NSString *scheme = [self requestHTTPScheme];
    if (!scheme) {
        if (complete) {
            complete(nil, [NSError errorWithDomain:WWTRequestErrorDomain_URL code:0 userInfo:nil]);
        }
        return;
    }
    
    if ([self requestHTTPDNS]) {
        
        NSString *url = [NSString stringWithFormat:@"%@://%@", scheme, domain];
        NSString *path = [self requestHTTPPath];
        if (path) {
            url = [url stringByAppendingString:path];
        }
        
        NSError *reqErr = nil;
        NSMutableURLRequest *request = [self request:url error:&reqErr];
        if (complete) {
            complete(request, reqErr);
        }
    }
    else {
        NSString *url = [NSString stringWithFormat:@"%@://%@", scheme, domain];
        NSString *path = [self requestHTTPPath];
        if (path) {
            url = [url stringByAppendingString:path];
        }
        
        NSError *reqErr = nil;
        NSMutableURLRequest *request = [self request:url error:&reqErr];
        if (complete) {
            complete(request, reqErr);
        }
    }
}

//------------------------------------------------------------------------
#pragma mark - Events
//------------------------------------------------------------------------

- (id)dataAfterSync:(NSError *__autoreleasing *)error
{
    //request
    NSError *net_error = nil;
    NSMutableURLRequest *request = [self requestAfterSync:&net_error];
    if (net_error) {
        *error = net_error;
        return nil;
    }
    
    self.request = request;
    
    // network
    WWTNetwork *net = [self requestNetwork];
    if (!net || ![net respondsToSelector:@selector(syncDataTaskWithRequest:response:responseObj:responseErr:)]) {
        *error = [self wtfError];
        return nil;
    }
    
    // sync
    NSURLResponse *net_response = nil;
    id             net_obj      = nil;
    
    [net syncDataTaskWithRequest:request
                        response:&net_response
                     responseObj:&net_obj
                     responseErr:&net_error];
    
    
    self.response    = (NSHTTPURLResponse *)net_response;
    self.responseObj = net_obj;
    self.responseErr = net_error;
    
    
    // error
    NSError *rest_error = [self restError];
    if (rest_error) {
        
        self.requestErr = rest_error;
        
        // log
#if DEBUG
        NSString *log = self.description;
        if (log) {
            printf("%s", [log UTF8String]);
        }
#endif
        
        if (error) {
            *error = rest_error;
        }
        
        return nil;
    }
    
    // result
    return net_obj;
}

- (void)async:(void (^)(NSURLResponse *response, id responseObject, NSError *error))complete
{
    //request
    [self requestAfterAsync:^(NSMutableURLRequest *request, NSError *error) {
        
        if (error) {
            if (complete) {
                complete(nil, nil, error);
            }
            return;
        }
        
        self.request = request;
        
        // network
        WWTNetwork *net = [self requestNetwork];
        if (!net || ![net respondsToSelector:@selector(asyncDataTaskWithRequest:complete:)]) {
            complete(nil, nil, [self wtfError]);
            return;
        }
        
        // async
        [net asyncDataTaskWithRequest:request complete:^(NSURLResponse *net_response, id net_obj, NSError *net_error) {
            
            self.response    = (NSHTTPURLResponse *)net_response;
            self.responseObj = net_obj;
            self.responseErr = net_error;
            
            // error
            NSError *rest_error = [self restError];
            if (rest_error) {
                
                self.requestErr = rest_error;
                
                // log
#if DEBUG
                NSString *log = self.description;
                if (log) {
                    printf("%s", [log UTF8String]);
                }
#endif
                
                // call back
                if (complete) {
                    complete(net_response, net_obj, rest_error);
                }
                return;
            }
            
            // success
            // call back
            if (complete) {
                complete(net_response, net_obj, nil);
            }
        }];
    }];
}



//------------------------------------------------------------------------
#pragma mark - Error Methods
//------------------------------------------------------------------------

- (NSError *)restError
{
    // 无服务响应错误 (如: 断网等)
    if (!self.response && self.responseErr) {
        return [self netError];
    }
    
    NSString *code = [self errorCodeFromRequest];
    NSString *msg  = [self errorMsgFromRequest];
    
    // 没有错误
    if (!code && !self.responseErr) {
        return nil;
    }
    
    NSMutableDictionary *errInfo = [@{} mutableCopy];
    [errInfo wwt_setObject:[self requestHTTPDomain]      forKey:WWTRequestErrorInfoKey_Domain];
    [errInfo wwt_setObject:NSStringFromClass(self.class) forKey:WWTRequestErrorInfoKey_Class];
    [errInfo wwt_setObject:self.responseObj              forKey:WWTRequestErrorInfoKey_Response];
    [errInfo wwt_setObject:code                          forKey:WWTRequestErrorInfoKey_Code];
    [errInfo wwt_setObject:msg                           forKey:WWTRequestErrorInfoKey_Msg];
    
    NSError *error = [NSError errorWithDomain:WWTRequestErrorDomain_Request
                                         code:self.response.statusCode
                                     userInfo:errInfo];
    return error;
}

- (NSError *)netError
{
    NSString *code = @"netError";
    NSString *msg  = self.responseErr.localizedDescription;
    
    if (self.responseErr.code == NSURLErrorTimedOut) {
        code = @"netTimeout";
    }
    
    NSMutableDictionary *errInfo = [@{} mutableCopy];
    [errInfo wwt_setObject:[self requestHTTPDomain]      forKey:WWTRequestErrorInfoKey_Domain];
    [errInfo wwt_setObject:NSStringFromClass(self.class) forKey:WWTRequestErrorInfoKey_Class];
    [errInfo wwt_setObject:self.responseObj              forKey:WWTRequestErrorInfoKey_Response];
    [errInfo wwt_setObject:code                          forKey:WWTRequestErrorInfoKey_Code];
    [errInfo wwt_setObject:msg                           forKey:WWTRequestErrorInfoKey_Msg];
    
    NSError *error = [NSError errorWithDomain:WWTRequestErrorDomain_Request
                                         code:self.response.statusCode
                                     userInfo:errInfo];
    return error;
}

- (NSError *)parasError
{
    NSString *code = @"parasError";
    NSString *msg  = @"Parameters Error.";
    
    NSMutableDictionary *errInfo = [@{} mutableCopy];
    [errInfo wwt_setObject:[self requestHTTPDomain]      forKey:WWTRequestErrorInfoKey_Domain];
    [errInfo wwt_setObject:NSStringFromClass(self.class) forKey:WWTRequestErrorInfoKey_Class];
    [errInfo wwt_setObject:self.responseObj              forKey:WWTRequestErrorInfoKey_Response];
    [errInfo wwt_setObject:code                          forKey:WWTRequestErrorInfoKey_Code];
    [errInfo wwt_setObject:msg                           forKey:WWTRequestErrorInfoKey_Msg];
    
    NSError *error = [NSError errorWithDomain:WWTRequestErrorDomain_Request
                                         code:self.response.statusCode
                                     userInfo:errInfo];
    return error;
}

- (NSError *)wtfError
{
    NSString *code = @"unknown error";
    NSString *msg  = @"WTF!";
    
    NSMutableDictionary *errInfo = [@{} mutableCopy];
    [errInfo wwt_setObject:[self requestHTTPDomain]      forKey:WWTRequestErrorInfoKey_Domain];
    [errInfo wwt_setObject:NSStringFromClass(self.class) forKey:WWTRequestErrorInfoKey_Class];
    [errInfo wwt_setObject:self.responseObj              forKey:WWTRequestErrorInfoKey_Response];
    [errInfo wwt_setObject:code                          forKey:WWTRequestErrorInfoKey_Code];
    [errInfo wwt_setObject:msg                           forKey:WWTRequestErrorInfoKey_Msg];
    
    NSError *error = [NSError errorWithDomain:WWTRequestErrorDomain_Request
                                         code:self.response.statusCode
                                     userInfo:errInfo];
    return error;
}
//------------------------------------------------------------------------
#pragma mark - Getter
//------------------------------------------------------------------------

- (NSString *)method
{
    return [self requestHTTPMethod];
}

- (NSString *)baseURL
{
    return [self requestBaseURL];
}

- (NSString *)fullURL
{
    return [self requestFullURL];
}

//------------------------------------------------------------------------
#pragma mark - <WWTRequesting>
//------------------------------------------------------------------------

- (NSString *)requestHTTPMethod
{
    return WWTNetworkRequestMethod_GET;
}

- (NSString *)requestHTTPScheme
{
    return WWTNetworkRequestURLScheme_HTTPS;
}

- (NSString *)requestHTTPDomain
{
    // TODO:
    return @"www.wewave.com.cn/api";
    
}

- (NSString *)requestHTTPPath
{
    return nil;
}

- (BOOL)requestHTTPDNS
{
    return NO;
}

- (NSDictionary *)requestIncreParameter
{
    return nil;
}

- (NSArray *)requestCookies
{
    return nil;
}

- (NSDictionary *)requestHeaders
{
    NSMutableDictionary *headers = [@{} mutableCopy];
    [headers wwt_setObject:[WWTDevice uuid]                 forKey:@"WWT-DeviceID"];
    [headers wwt_setObject:[WWTDevice deviceModel]          forKey:@"WWT-DeviceProductID"];
    [headers wwt_setObject:[WWTDevice systemVersion]        forKey:@"WWT-SystemVersion"];
    [headers wwt_setObject:[WWTDevice deviceLanguage]       forKey:@"WWT-SystemLanguage"];
    [headers wwt_setObject:[WWTDevice deviceCountryCode]    forKey:@"WWT-SystemRegion"];

    return headers;
}

- (NSString *)errorCodeFromRequest
{
    return nil;
}

- (NSString *)errorMsgFromRequest
{
    return nil;
}

- (NSTimeInterval)requestTimeoutInterval
{
    return 10;
}

- (WWTNetwork *)requestNetwork
{
    return [WWTNetwork defaultNetwork];
}

- (NSURLRequestCachePolicy)RequestCachePolicy
{
    return NSURLRequestUseProtocolCachePolicy;
}

- (NSMutableURLRequest *)customRequestWithRequest:(NSMutableURLRequest *)request
{
    NSString *scheme = [self requestHTTPScheme];
//    NSString *contentType = [request valueForHTTPHeaderField:@"Content-Type"];
    
    // uri
    NSString *schemeStr = [scheme stringByAppendingString:@"://"];
    NSMutableString *uriStr = [request.URL.absoluteString mutableCopy];
    [uriStr replaceOccurrencesOfString:schemeStr withString:@"" options:0 range:NSMakeRange(0, uriStr.length)];
    
    // timestamp
//    NSString *timestamp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
//    [request setValue:timestamp   forHTTPHeaderField:@"ML-Timestamp"];
    
    return request;

}

//------------------------------------------------------------------------
#pragma mark - Description
//------------------------------------------------------------------------

- (NSString *)description
{
    // base
    NSString *method  = self.request.HTTPMethod;
    NSString *url     = self.request.URL.absoluteString;
    NSString *headers = self.request.allHTTPHeaderFields.description;
    NSString *code    = @(self.response.statusCode).stringValue;
    NSString *code_ds = [NSHTTPURLResponse localizedStringForStatusCode:self.response.statusCode].uppercaseString;
    
    // parameter
    NSDictionary *incre_parameter  = [self requestIncreParameter];
    NSDictionary *custom_parameter = self.parameter;
    
    NSMutableDictionary *parameter = [@{} mutableCopy];
    if (!incre_parameter && !custom_parameter) {
        parameter = nil;
    }
    if (incre_parameter) {
        [parameter addEntriesFromDictionary:incre_parameter];
    }
    if (custom_parameter) {
        [parameter addEntriesFromDictionary:custom_parameter];
    }
    
    NSMutableString *log = [@"" mutableCopy];
    [log appendString:@"\n##############################\n"];
    
    [log appendString:[NSString stringWithFormat:@" Code: %@ (%@)", code, code_ds]];
    [log appendString:@"\n"];
    
    [log appendString:[NSString stringWithFormat:@" [%@]  %@", method, url]];
    [log appendString:@"\n"];
    
    [log appendString:[NSString stringWithFormat:@" Request Headers:\n%@", headers]];
    [log appendString:@"\n"];
    
    [log appendString:[NSString stringWithFormat:@" Request Data:\n"]];
    [log appendString:[NSString stringWithFormat:@"%@", [parameter description]]];
    [log appendString:@"\n"];
    
    [log appendString:[NSString stringWithFormat:@" Response Data:\n"]];
    [log appendString:[NSString stringWithFormat:@"%@", [self.responseObj description]]];
    [log appendString:@"\n"];
    
    [log appendString:[NSString stringWithFormat:@" Request Error:\n"]];
    [log appendString:[NSString stringWithFormat:@"%@", [self.requestErr description]]];
    
    [log appendString:@"\n##############################\n\n"];
    
    return log;
}


@end
