//
//  WWTVibrate.h
//  WWTKit
//
//  Created by EamonLiang on 2019/4/28.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



typedef NS_ENUM(NSInteger, WWTVibrateType) {
    
    WWTVibrateNotificationErrorType = 1,
    WWTVibrateNotificationSuccessType,
    WWTVibrateNotificationWarningType,
    
    WWTVibrateImpactLightType,
    WWTVibrateImpactMediumType,
    WWTVibrateImpactHeavyType,
    
    WWTVibrateSelectionType,
    
    WWTVibrateAVFNopoType,
    WWTVibrateAVFPopType,
    WWTVibrateAVFPeekType,
};


//------------------------------------------------------------------------
#pragma mark - Interface (WWTVibrate)
//------------------------------------------------------------------------

@interface WWTVibrate : NSObject


+ (BOOL)canVirbate;

+ (BOOL)canFeedbackVirbate;

+ (BOOL)canAVFVirbate;

+ (void)virbateWithType:(WWTVibrateType)type;


@end
