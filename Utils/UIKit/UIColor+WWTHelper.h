//
//  UIColor+WWTHelper.h
//  WWTKit
//
//  Created by EamonLiang on 2019/4/17.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



//------------------------------------------------------------------------
#pragma mark - Macro
//------------------------------------------------------------------------

// wwt_rgb16
#define wwt_rgb16(rgbv, alp) [UIColor colorWithRed:((float)((rgbv & 0xFF0000) >> 16))/255.0 green:((float)((rgbv & 0xFF00) >> 8))/255.0 blue:((float)(rgbv & 0xFF))/255.0 alpha:alp]

// wwt_rgb8
#define wwt_rgb8(redv, greenv, bluev, alp) [UIColor colorWithRed:((float)redv)/255.0 green:((float)greenv)/255.0 blue:((float)bluev)/255.0 alpha:alp]

// wwt_cg_rgb16
#define wwt_cg_rgb16(rgbv, alp) [UIColor colorWithRed:((float)((rgbv & 0xFF0000) >> 16))/255.0 green:((float)((rgbv & 0xFF00) >> 8))/255.0 blue:((float)(rgbv & 0xFF))/255.0 alpha:alp].CGColor

// wwt_cg_rgb8
#define wwt_cg_rgb8(redv, greenv, bluev, alp) [UIColor colorWithRed:((float)redv)/255.0 green:((float)greenv)/255.0 blue:((float)bluev)/255.0 alpha:alp].CGColor


//------------------------------------------------------------------------
#pragma mark - Interface (UIColor + WWTHelper)
//------------------------------------------------------------------------

@interface UIColor (WWTHelper)

/**
 根据string类型的rgba返回UIColor
 
 @param rgba r,g,b,a
 @return 对应UIColor
 */
+ (UIColor *)wwt_colorWithRGBA:(NSString *)rgba;

/**
 混合颜色
 
 @param c1 color1
 @param c2 color2
 @param alpha 不透明度
 @return UIColor
 */
+ (UIColor *)wwt_blendColor:(UIColor *)c1 withColor:(UIColor *)c2 alpha:(float)alpha;


@end
