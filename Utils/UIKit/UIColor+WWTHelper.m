//
//  UIColor+WWTHelper.m
//  WWTKit
//
//  Created by EamonLiang on 2019/4/17.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import "UIColor+WWTHelper.h"



//------------------------------------------------------------------------
#pragma mark - Implementation (UIColor + WWTHelper)
//------------------------------------------------------------------------

@implementation UIColor (WWTHelper)


+ (UIColor *)wwt_colorWithRGBA:(NSString *)rgba
{
    NSArray *group = [rgba componentsSeparatedByString:@","];
    if (!rgba || group.count != 4) {
        return nil;
    }
    
    float r = [group[0] floatValue];
    float g = [group[1] floatValue];
    float b = [group[2] floatValue];
    float a = [group[3] floatValue];
    
    UIColor *color = [UIColor colorWithRed:r/255.f green:g/255.f blue:b/255.f alpha:a];
    return color;
}

+ (UIColor *)wwt_blendColor:(UIColor *)c1 withColor:(UIColor *)c2 alpha:(float)alpha
{
    alpha = MIN(1.0f, MAX(0.f, alpha));
    float beta = 1.0f - alpha;
    
    CGFloat r1, g1, b1, a1, r2, g2, b2, a2;
    
    [c1 getRed:&r1 green:&g1 blue:&b1 alpha:&a1];
    [c2 getRed:&r2 green:&g2 blue:&b2 alpha:&a2];
    
    CGFloat r = r1 * beta + r2 * alpha;
    CGFloat g = g1 * beta + g2 * alpha;
    CGFloat b = b1 * beta + b2 * alpha;
    
    UIColor *color = [UIColor colorWithRed:r green:g blue:b alpha:1.f];
    return color;
}


@end
