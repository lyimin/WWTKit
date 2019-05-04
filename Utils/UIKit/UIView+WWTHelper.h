//
//  UIView+WWTHelper.h
//  WWTKit
//
//  Created by EamonLiang on 2019/4/16.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import <UIKit/UIKit.h>



//------------------------------------------------------------------------
#pragma mark - Interface (UIView + WWTHelper)
//------------------------------------------------------------------------

@interface UIView (WWTHelper)

@property (nonatomic) CGFloat x;        // Shortcut for frame.origin.x.
@property (nonatomic) CGFloat y;         // Shortcut for frame.origin.y
@property (nonatomic) CGFloat right;       // Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat bottom;      // Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat width;       // Shortcut for frame.size.width.
@property (nonatomic) CGFloat height;      // Shortcut for frame.size.height.
@property (nonatomic) CGFloat centerX;     // Shortcut for center.x
@property (nonatomic) CGFloat centerY;     // Shortcut for center.y
@property (nonatomic) CGPoint origin;      // Shortcut for frame.origin.
@property (nonatomic) CGSize  size;        // Shortcut for frame.size.


/**
 添加点击事件
 */
- (void)viewAddTarget:(id)target action:(SEL)action;


@end
