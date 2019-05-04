//
//  UIImage+WWTHelper.h
//  WWTKit
//
//  Created by EamonLiang on 2019/4/16.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



// 圆角
typedef NS_ENUM(NSInteger, WWTImageRoundedCornerCorner) {
   WWTImageRoundedCornerCornerTopLeft     = 1,
   WWTImageRoundedCornerCornerTopRight    = 1 << 1,
   WWTImageRoundedCornerCornerBottomRight = 1 << 2,
   WWTImageRoundedCornerCornerBottomLeft  = 1 << 3
};


//------------------------------------------------------------------------
#pragma mark - Interface (UIImage + WWTHelper)
//------------------------------------------------------------------------

@interface UIImage (WWTHelper)

/**
 返回1px的纯色UIImage
 */
+ (UIImage *)wwt_imageWithColor:(UIColor *)color;


/**
 高性能绘圆形图片
 
 @return 圆形图片
 */
- (UIImage *)rounded;

/**
 高性能绘制圆角图片(默认绘制4个圆角)
 
 @param radius 圆角
 @return 圆角图片
 */
- (UIImage *)roundedWithRadius:(CGFloat)radius;

/**
 高性能绘制圆角图片
 
 @param radius 圆角
 @param cornerMask 要绘制的圆角
 @return 圆角图片
 */
- (UIImage *)roundedWithRadius:(CGFloat)radius
                    cornerMask:(WWTImageRoundedCornerCorner)cornerMask;


@end
