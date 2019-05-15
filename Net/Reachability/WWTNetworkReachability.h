//
//  WWTNetworkReachability.h
//  WWTKit
//
//  Created by eamon on 2019/4/2.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


//------------------------------------------------------------------------
#pragma mark - Contents
//------------------------------------------------------------------------

typedef NS_ENUM(NSInteger, WWTNetworkReachabilityStatus) {
    WWTNetworkReachabilityStatusUnknown          = -1,   // 未知
    WWTNetworkReachabilityStatusNotReachable     = 0,    // 没有网络
    WWTNetworkReachabilityStatusReachableViaWWAN = 1,    // 3G/4G
    WWTNetworkReachabilityStatusReachableViaWiFi = 2,    // WIFI
};

extern NSString * const WWTNetworkReachabilityStatusUnknownIdentify;          // unknow
extern NSString * const WWTNetworkReachabilityStatusNotReachableIdentify;     // not
extern NSString * const WWTNetworkReachabilityStatusReachableViaWWANIdentify; // wwan
extern NSString * const WWTNetworkReachabilityStatusReachableViaWiFiIdentify; // wifi


/// 监听到网络状态改变时回调
typedef void(^WWTNetworkReachabilityStatusChangeBlock)(WWTNetworkReachabilityStatus status);



//------------------------------------------------------------------------
#pragma mark - Interface (WWTNetworkReachability)
//------------------------------------------------------------------------

@interface WWTNetworkReachability : NSObject


/**
 Single
 */
+ (instancetype)standardReachability;


/**
 开始监听. 当网络状态更改时, status会更新, block会触发回调
 */
- (void)startMonitoringWithBlock:(WWTNetworkReachabilityStatusChangeBlock)block;


/**
 停止监听. status不会再更新
 */
- (void)stopMonitoring;


/**
 网络状态

 @return WWTNetworkReachabilityStatus
 */
- (WWTNetworkReachabilityStatus)status;

/**
 网络状态字符串
 
 @return NSString
 */
- (NSString *)statusIdentify;


@end
