//
//  UINavigationController+WWTHelper.m
//  WWTKit
//
//  Created by EamonLiang on 2019/4/18.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import "UINavigationController+WWTHelper.h"

#import "UIColor+WWTHelper.h"
#import "UIImage+WWTHelper.h"



//------------------------------------------------------------------------
#pragma mark - Implementation (UINavigationController + WWTHelper)
//------------------------------------------------------------------------

@implementation UINavigationController (WWTHelper)


- (void)wwt_presetNavBarWithStyle:(WWTNavBarPresetStyle)style
{
    UIColor *tintColor = nil;
    UIColor *bgColor   = nil;
    switch (style) {
        case WWTNavBarPresetWhiteStyle:
            tintColor = wwt_rgb8(0, 0, 0, 1);
            bgColor   = wwt_rgb8(255, 255, 255, 1);
            break;
        case WWTNavBarPresetBlackStyle:
            tintColor = wwt_rgb8(255, 255, 255, 1);
            bgColor   = wwt_rgb8(0, 0, 0, 1);
            break;
        default:
            tintColor = wwt_rgb8(255, 255, 255, 1);
            bgColor   = wwt_rgb8(0, 0, 0, 1);
            break;
    }
    
    [self wwt_setNavBarBackgroundColor:bgColor];
    [self wwt_setNavBarTintColor:tintColor];
    [self wwt_setNavBarTitleWithText:self.title textColor:tintColor];
}

- (void)wwt_setNavBarBackgroundClear
{
    [self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
}

- (void)wwt_setNavBarBackgroundColor:(UIColor *)color
{
    if (!color) {
        return;
    }
    UIImage *colorImg = [UIImage wwt_imageWithColor:color];
    if (!colorImg) {
        return;
    }
    [self.navigationBar setBackgroundImage:colorImg forBarMetrics:UIBarMetricsDefault];
    [self.navigationBar setShadowImage:[UIImage new]];
}

- (void)wwt_setNavBarTintColor:(UIColor *)color
{
    if (!color) {
        return;
    }
    [self.navigationBar setTintColor:color];
}

- (void)wwt_setNavBarLeftButtonWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    if (!image) {
        self.navigationItem.leftBarButtonItems = @[];
        return;
    }
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
    self.navigationBar.topItem.leftBarButtonItems = @[btn];
}

- (void)wwt_setNavBarLeftButtonWithText:(NSString *)text textColor:(UIColor *)color  target:(id)target action:(SEL)action
{
    if (!text) {
        self.navigationItem.leftBarButtonItems = @[];
        return;
    }
    
    UIColor *textColor = color ?: self.navigationBar.tintColor;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:27.f weight:UIFontWeightSemibold]];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationBar.topItem.rightBarButtonItems = @[btnItem];
}

- (void)wwt_setNavBarRightButtonWithImage:(UIImage *)image target:(id)target action:(SEL)action
{
    if (!image) {
        self.navigationItem.rightBarButtonItems = @[];
        return;
    }
    UIBarButtonItem *btn = [[UIBarButtonItem alloc] initWithImage:image style:UIBarButtonItemStylePlain target:target action:action];
    self.navigationItem.rightBarButtonItems = @[btn];
}

- (void)wwt_setNavBarRightButtonWithText:(NSString *)text textColor:(UIColor *)color target:(id)target action:(SEL)action
{
    if (!text) {
        self.navigationItem.rightBarButtonItems = @[];
        return;
    }
    
    UIColor *textColor = color ?: self.navigationBar.tintColor;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    [btn.titleLabel setFont:[UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold]];
    [btn sizeToFit];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItems = @[btnItem];
}

- (void)wwt_setNavBarTitleWithText:(NSString *)title textColor:(UIColor *)color
{
    UIColor *textColor = color ?: self.navigationBar.tintColor;
    NSDictionary *att = @{
                          NSFontAttributeName: [UIFont systemFontOfSize:17.f weight:UIFontWeightSemibold],
                          NSForegroundColorAttributeName: textColor,
                          };
    [self.navigationBar setTitleTextAttributes:att];
    self.topViewController.title = title;
}


@end
