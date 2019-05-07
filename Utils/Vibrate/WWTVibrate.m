//
//  WWTVibrate.m
//  WWTKit
//
//  Created by EamonLiang on 2019/4/28.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import "WWTVibrate.h"

#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>
#import <sys/utsname.h>



//------------------------------------------------------------------------
#pragma mark - Implementation (WWTVibrate)
//------------------------------------------------------------------------

@implementation WWTVibrate


//------------------------------------------------------------------------
#pragma mark - Public Methods
//------------------------------------------------------------------------

+ (BOOL)canVirbate
{
    return (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
}

+ (BOOL)canFeedbackVirbate
{
    if (![self canVirbate]) {
        return NO;
    }
    
    if (@available(iOS 10.0, *)) {
        if ([self phoneModelNum]) {
            return [self phoneModelNum].integerValue >= 9;
        }
    }
    
    return NO;
}

+ (BOOL)canAVFVirbate
{
    if (![self canVirbate]) {
        return NO;
    }
    
    if ([self phoneModelNum]) {
        return [self phoneModelNum].integerValue >= 8;
    }
    
    return NO;
}

+ (void)virbateWithType:(WWTVibrateType)type
{
    /*
     *  main thread
     */
    if (![NSThread isMainThread]) {
        return;
    }
    
    // [feedback] 类型
    if ([self canFeedbackVirbate]) {
        
        // 只有在前台才使用feedback类型
        BOOL isAppActive =
        (UIApplication.sharedApplication.applicationState == UIApplicationStateActive);
        
        if (isAppActive) {
            [self feedbadk_virbate:type];
        }
        else {
            [self avf_virbate:type];
        }
    }
    // [avf] 类型
    else if ([self canAVFVirbate]) {
        
        [self avf_virbate:type];
    }
}


//------------------------------------------------------------------------
#pragma mark - Private Methods
//------------------------------------------------------------------------

+ (void)feedbadk_virbate:(WWTVibrateType)type
{
    switch (type) {
            
        case WWTVibrateNotificationErrorType: {
            if (@available(iOS 10.0, *)) {
                UINotificationFeedbackGenerator *generator = [UINotificationFeedbackGenerator new];
                [generator notificationOccurred:UINotificationFeedbackTypeError];
            }
            break;
        }
        case WWTVibrateNotificationSuccessType: {
            if (@available(iOS 10.0, *)) {
                UINotificationFeedbackGenerator *generator = [UINotificationFeedbackGenerator new];
                [generator notificationOccurred:UINotificationFeedbackTypeSuccess];
            }
            break;
        }
        case WWTVibrateNotificationWarningType: {
            if (@available(iOS 10.0, *)) {
                UINotificationFeedbackGenerator *generator = [[UINotificationFeedbackGenerator alloc] init];
                [generator notificationOccurred:UINotificationFeedbackTypeWarning];
            }
            break;
        }
            
        case WWTVibrateImpactLightType: {
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
                [generator impactOccurred];
            }
            break;
        }
        case WWTVibrateImpactMediumType: {
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleMedium];
                [generator impactOccurred];
            }
            break;
        }
        case WWTVibrateImpactHeavyType: {
            if (@available(iOS 10.0, *)) {
                UIImpactFeedbackGenerator *generator = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
                [generator impactOccurred];
            }
            break;
        }
            
        case WWTVibrateSelectionType: {
            if (@available(iOS 10.0, *)) {
                UISelectionFeedbackGenerator *generator = [[UISelectionFeedbackGenerator alloc] init];
                [generator selectionChanged];
            }
            break;
        }
            
        case WWTVibrateAVFNopoType: {
            [self avf_virbate:WWTVibrateAVFNopoType];
            break;
        }
        case WWTVibrateAVFPopType: {
            [self avf_virbate:WWTVibrateAVFPopType];
            break;
        }
        case WWTVibrateAVFPeekType: {
            [self avf_virbate:WWTVibrateAVFPeekType];
            break;
        }
            
        default:
            break;
    }
}

+ (void)avf_virbate:(WWTVibrateType)type
{
    SystemSoundID peek = 1519; // weak
    SystemSoundID pop  = 1520; // strong
    SystemSoundID nope = 1521; // three weak
    
    switch (type) {
            
        case WWTVibrateNotificationErrorType: {
            AudioServicesPlaySystemSound(nope);
            break;
        }
        case WWTVibrateNotificationSuccessType: {
            AudioServicesPlaySystemSound(nope);
            break;
        }
        case WWTVibrateNotificationWarningType: {
            AudioServicesPlaySystemSound(nope);
            break;
        }
            
        case WWTVibrateImpactLightType: {
            AudioServicesPlaySystemSound(pop);
            break;
        }
        case WWTVibrateImpactMediumType: {
            AudioServicesPlaySystemSound(pop);
            break;
        }
        case WWTVibrateImpactHeavyType: {
            AudioServicesPlaySystemSound(pop);
            break;
        }
            
        case WWTVibrateSelectionType: {
            AudioServicesPlaySystemSound(peek);
            break;
        }
            
        case WWTVibrateAVFNopoType: {
            AudioServicesPlaySystemSound(nope);
            break;
        }
        case WWTVibrateAVFPopType: {
            AudioServicesPlaySystemSound(pop);
            break;
        }
        case WWTVibrateAVFPeekType: {
            AudioServicesPlaySystemSound(peek);
            break;
        }
            
        default:
            break;
    }
}


static NSNumber *__PhoneModelNum__ = nil;

+ (NSNumber *)phoneModelNum
{
    if (__PhoneModelNum__) {
        return __PhoneModelNum__;
    }
    
    struct utsname systemInfo; uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    NSRange iphoneRange = [deviceString rangeOfString:@"iPhone"];
    if (iphoneRange.location != NSNotFound) {
        
        NSString *modelNumsStr = [deviceString substringFromIndex:iphoneRange.location + iphoneRange.length];
        NSArray  *modelNums    = [modelNumsStr componentsSeparatedByString:@","];
        NSInteger modelNum     = [modelNums[0] integerValue];
        
        __PhoneModelNum__ = @(modelNum);
        return @(modelNum);
    }
    
    return nil;
}


@end
