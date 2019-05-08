//
//  NSString+WWTHelper.h
//  WWTKit
//
//  Created by eamon on 2019/4/3.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 判断字符串是否为空
 
 @param str 传入的字符串
 @return 是否为空
 */
static inline BOOL wwt_emptyStr(NSString *str)
{
    if (!str) {
        return YES;
    }
    
    if ([str isKindOfClass:[NSString class]]) {
        return str.length == 0;
    }
    
    return NO;
}

//------------------------------------------------------------------------
#pragma mark - Interface (NSString + WWTHelper)
//------------------------------------------------------------------------

@interface NSString (WWTHelper)


/**
 字符串 转 字典类型
 */
- (NSDictionary *)wwt_toDictionary;


@end
