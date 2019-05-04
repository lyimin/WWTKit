//
//  UIView+WWTHelper.m
//  WWTKit
//
//  Created by EamonLiang on 2019/4/16.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import "UIView+WWTHelper.h"
#import <objc/runtime.h>


NSString const *WWTViewBlockTapKey = @"WWTViewBlockTapKey";



//------------------------------------------------------------------------
#pragma mark - Implementation (UIView + WWTHelper)
//------------------------------------------------------------------------

@implementation UIView (WWTHelper)


- (CGFloat)x
{
    return self.frame.origin.x;
}

- (void)setX:(CGFloat)x
{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

- (CGFloat)y
{
    return self.frame.origin.y;
}

- (void)setY:(CGFloat)y
{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right
{
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect frame = self.frame;
    frame.origin.y = bottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)width
{
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width
{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height
{
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height
{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

- (CGFloat)centerX
{
    return self.center.x;
}

- (void)setCenterX:(CGFloat)centerX
{
    self.center = CGPointMake(centerX, self.center.y);
}

- (CGFloat)centerY
{
    return self.center.y;
}

- (void)setCenterY:(CGFloat)centerY
{
    self.center = CGPointMake(self.center.x, centerY);
}

- (CGPoint)origin
{
    return self.frame.origin;
}

- (void)setOrigin:(CGPoint)origin
{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

- (CGSize)size
{
    return self.frame.size;
}

- (void)setSize:(CGSize)size
{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

- (void)viewAddTarget:(id)target action:(SEL)action
{
    self.userInteractionEnabled = true;
    
    // 添加相同事件方法，，先将原来的事件移除，避免重复调用
    NSMutableArray *taps = [self allUIViewBlockTaps];
    [taps enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UITapGestureRecognizer *tap = (UITapGestureRecognizer *)obj;
        [self removeGestureRecognizer:tap];
    }];
    [taps removeAllObjects];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
    [self addGestureRecognizer:tap];
    [taps addObject:tap];
}


- (NSMutableArray *)allUIViewBlockTaps
{
    NSMutableArray *taps = objc_getAssociatedObject(self, &WWTViewBlockTapKey);
    if (!taps) {
        taps = [NSMutableArray array];
        objc_setAssociatedObject(self, &WWTViewBlockTapKey, taps, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return taps;
}



@end
