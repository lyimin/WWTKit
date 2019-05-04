//
//  UINavigationController+WWTHelper.h
//  WWTKit
//
//  Created by EamonLiang on 2019/4/18.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef NS_ENUM(NSInteger, WWTNavBarPresetStyle) {
    
    WWTNavBarPresetBlackStyle = 0,   
    WWTNavBarPresetWhiteStyle
};

//------------------------------------------------------------------------
#pragma mark - Interface (UINavigationController + WWTHelper)
//------------------------------------------------------------------------

@interface UINavigationController (WWTHelper)

/**
 设置导航栏样色
 */
- (void)wwt_presetNavBarWithStyle:(WWTNavBarPresetStyle)style;

/**
 清除系统导航栏背景色
 */
- (void)wwt_setNavBarBackgroundClear;

/**
 设置导航栏背景色
 */
- (void)wwt_setNavBarBackgroundColor:(UIColor *)color;

/**
 设置导航栏内容颜色
 */
- (void)wwt_setNavBarTintColor:(UIColor *)color;


/**
 设置导航栏左边按钮
 
 @param image 左边按钮图片
 @param target 点击事件接受者
 @param action 点击事件处理
 */
- (void)wwt_setNavBarLeftButtonWithImage:(UIImage *)image target:(id)target action:(SEL)action;

/**
 设置导航栏左边按钮
 
 @param text 左边按钮文本
 @param color 文本颜色
 @param target 点击事件接受者
 @param action 点击事件处理
 */
- (void)wwt_setNavBarLeftButtonWithText:(NSString *)text textColor:(UIColor *)color target:(id)target action:(SEL)action;

/**
 设置导航栏右边按钮图片
 
 @param image 右边按钮图片
 @param target 点击事件接受者
 @param action 点击事件处理
 */
- (void)wwt_setNavBarRightButtonWithImage:(UIImage *)image target:(id)target action:(SEL)action;

/**
 设置导航栏右边按钮文本
 
 @param text 右边按钮文本
 @param color 文本颜色
 @param target 点击事件接受者
 @param action 点击事件处理
 */
- (void)wwt_setNavBarRightButtonWithText:(NSString *)text textColor:(UIColor *)color target:(id)target action:(SEL)action;

/**
 设置导航栏标题
 
 @param title 标题
 @param color 颜色
 */
- (void)wwt_setNavBarTitleWithText:(NSString *)title textColor:(UIColor *)color;



@end
