//
//  NSArray+WWTHelper.h
//  WWTKit
//
//  Created by EamonLiang on 2019/4/29.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



//------------------------------------------------------------------------
#pragma mark - Interface (NSArray + WWTHelper)
//------------------------------------------------------------------------

@interface NSArray (WWTHelper)


/**
 将一个数组平局分成自定数量的组

 @param count 每组的数量
 */
- (NSArray *)groupWithCount:(NSInteger)count;

@end
