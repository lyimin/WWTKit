//
//  WWTNetworkReachability.m
//  WWTKit
//
//  Created by eamon on 2019/4/2.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import "WWTNetworkReachability.h"

#import "WWTKitMacro.h"
#import "AFNetworking.h"



//------------------------------------------------------------------------
#pragma mark - Contents
//------------------------------------------------------------------------

//MARK: >> Status
//------------------------------------------------------------------------

NSString * const WWTNetworkReachabilityStatusUnknownIdentify = @"unknow";
NSString * const WWTNetworkReachabilityStatusNotReachableIdentify = @"not";
NSString * const WWTNetworkReachabilityStatusReachableViaWWANIdentify = @"wwan";
NSString * const WWTNetworkReachabilityStatusReachableViaWiFiIdentify = @"wifi";

//------------------------------------------------------------------------
#pragma mark - Interface (WWTNetworkReachability)
//------------------------------------------------------------------------

@interface WWTNetworkReachability ()

@property (strong, nonatomic) AFNetworkReachabilityManager *manager;

@end


//------------------------------------------------------------------------
#pragma mark - Implementation (WWTNetworkReachability)
//------------------------------------------------------------------------

@implementation WWTNetworkReachability


+ (instancetype)standardReachability
{
    static WWTNetworkReachability *_reachbility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _reachbility = [[WWTNetworkReachability alloc] init];
        _reachbility.manager = [AFNetworkReachabilityManager manager];
    });
    return _reachbility;
}


//---------------------------------------------------------------------------------------------------
#pragma mark - Monitor
//---------------------------------------------------------------------------------------------------

- (void)startMonitoringWithBlock:(WWTNetworkReachabilityStatusChangeBlock)block
{
    @weakify(self)
    [_manager startMonitoring];
    [_manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        if (block) {
            WWTNetworkReachabilityStatus status = [weak_self status];
            block(status);
        }
    }];
}

- (void)stopMonitoring
{
    [_manager stopMonitoring];
    [_manager setReachabilityStatusChangeBlock:nil];
}


//---------------------------------------------------------------------------------------------------
#pragma mark - Status
//---------------------------------------------------------------------------------------------------

- (WWTNetworkReachabilityStatus)status
{
    WWTNetworkReachabilityStatus status = WWTNetworkReachabilityStatusUnknown;
    switch (_manager.networkReachabilityStatus) {
        case AFNetworkReachabilityStatusUnknown:
            status = WWTNetworkReachabilityStatusUnknown;
            break;
        case AFNetworkReachabilityStatusNotReachable:
            status = WWTNetworkReachabilityStatusNotReachable;
            break;
        case AFNetworkReachabilityStatusReachableViaWWAN:
            status = WWTNetworkReachabilityStatusReachableViaWWAN;
            break;
        case AFNetworkReachabilityStatusReachableViaWiFi:
            status = WWTNetworkReachabilityStatusReachableViaWiFi;
            break;
        default:
            status = WWTNetworkReachabilityStatusUnknown;
            break;
    }
    return status;
}

- (NSString *)statusIdentify
{
    NSString *string = WWTNetworkReachabilityStatusUnknownIdentify;
    switch (self.status) {
        case WWTNetworkReachabilityStatusUnknown:
            string = WWTNetworkReachabilityStatusUnknownIdentify;
            break;
        case WWTNetworkReachabilityStatusNotReachable:
            string = WWTNetworkReachabilityStatusNotReachableIdentify;
            break;
        case WWTNetworkReachabilityStatusReachableViaWWAN:
            string = WWTNetworkReachabilityStatusReachableViaWWANIdentify;
            break;
        case WWTNetworkReachabilityStatusReachableViaWiFi:
            string = WWTNetworkReachabilityStatusReachableViaWiFiIdentify;
            break;
        default:
            break;
    }
    return string;
}


@end
