//
//  UIImage+WWTHelper.m
//  WWTKit
//
//  Created by EamonLiang on 2019/4/16.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import "UIImage+WWTHelper.h"



//------------------------------------------------------------------------
#pragma mark - Implementation (UIImage + WWTHelper)
//------------------------------------------------------------------------

@implementation UIImage (WWTHelper)


+ (UIImage *)wwt_imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


/**
 UIKit坐标系统原点在左上角，y方向向下的（坐标系A），但在Quartz中坐标系原点在左下角，y方向向上的(坐标系B)。图片绘制也是颠倒的。
 */
void addRoundedRectToPath(CGContextRef context, CGRect rect, float radius, WWTImageRoundedCornerCorner cornerMask)
{
    // 原点在左下方，y方向向上。移动到线条2的起点。
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + radius);
    
    // 画出线条2, 目前画线的起始点已经移动到线条2的结束地方了。
    CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height - radius);
    
    // 如果左上角需要画圆角，画出一个弧线出来。
    if (cornerMask & WWTImageRoundedCornerCornerTopLeft) {
        // 已左上的正方形的右下脚为圆心，半径为radius， 180度到90度画一个弧线，
        CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + rect.size.height - radius,
                        radius, M_PI, M_PI / 2, 1);
    }
    else {
        // 如果不需要画左上角的弧度。从线2终点，画到线3的终点，
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + rect.size.height);
        
        // 线3终点，画到线4的起点
        CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y + rect.size.height);
    }
    // 画线4的起始，到线4的终点
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius,
                            rect.origin.y + rect.size.height);
    // 画右上角
    if (cornerMask & WWTImageRoundedCornerCornerTopRight) {
        CGContextAddArc(context, rect.origin.x + rect.size.width - radius,
                        rect.origin.y + rect.size.height - radius, radius, M_PI / 2, 0.0f, 1);
    }
    else {
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - radius);
    }
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + radius);
    
    //画右下角弧线
    if (cornerMask & WWTImageRoundedCornerCornerBottomRight) {
        CGContextAddArc(context, rect.origin.x + rect.size.width - radius, rect.origin.y + radius,
                        radius, 0.0f, -M_PI / 2, 1);
    }
    else {
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - radius, rect.origin.y);
    }
    CGContextAddLineToPoint(context, rect.origin.x + radius, rect.origin.y);
    //画左下角弧线
    if (cornerMask & WWTImageRoundedCornerCornerBottomLeft) {
        CGContextAddArc(context, rect.origin.x + radius, rect.origin.y + radius, radius,
                        -M_PI / 2, M_PI, 1);
    }
    else {
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + radius);
    }
    CGContextClosePath(context);
}

- (UIImage *)rounded
{
    if (!self) return nil;
    CGFloat radius = MIN(self.size.width, self.size.height) / 2.0;
    return [self roundedWithRadius:radius];
}

- (UIImage *)roundedWithRadius:(CGFloat)radius
{
    return [self roundedWithRadius:radius cornerMask:WWTImageRoundedCornerCornerBottomLeft | WWTImageRoundedCornerCornerBottomRight | WWTImageRoundedCornerCornerTopLeft | WWTImageRoundedCornerCornerTopRight];
}

- (UIImage *)roundedWithRadius:(CGFloat)radius
                    cornerMask:(WWTImageRoundedCornerCorner)cornerMask
{
    if (!self) return nil;
    if (radius <= 0) return self;
    
    //UIImage绘制为圆角
    int w = self.size.width;
    int h = self.size.height;
    UIImage *newImage = self;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(NULL, w, h, 8, 4 * w, colorSpace, kCGImageAlphaPremultipliedFirst);
    CGRect rect = CGRectMake(0, 0, w, h);
    CGContextBeginPath(context);
    addRoundedRectToPath(context, rect, radius, cornerMask);
    CGContextClosePath(context);
    CGContextClip(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, w, h), newImage.CGImage);
    CGImageRef imageMasked = CGBitmapContextCreateImage(context);
    newImage = [UIImage imageWithCGImage:imageMasked];
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageMasked);
    
    return newImage;
}


@end
