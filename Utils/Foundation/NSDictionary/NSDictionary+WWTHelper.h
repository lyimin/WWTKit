//
//  NSDictionary+WWTHelper.h
//  WWTKit
//
//  Created by eamon on 2019/4/2.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



/**
 判断字典是否为空
 
 @param dict 传入的字典
 @return 是否为空
 */
static inline BOOL wwt_emptyDict(NSDictionary *dict)
{
    if (!dict) {
        return YES;
    }
    
    if ([dict isKindOfClass:[NSDictionary class]]) {
        return dict.allKeys.count == 0;
    }
    
    return NO;
}


//------------------------------------------------------------------------
#pragma mark - Interface (NSDictionary + WWTHelper)
//------------------------------------------------------------------------

@interface NSDictionary (WWTHelper)

+ (NSDictionary *)wwt_dictionaryFromJsonString:(NSString *)jsonString;

+ (NSString *)wwt_stringFromJsonDictionary:(NSDictionary *)jsonDictionary;

/*!
 *  NSDictionary 转 NSString
 */
- (NSString *)wwt_JSONString;

/*!
 *  NSDictionary 转 NSData
 */
- (NSData *)wwt_JSONData;


@end


//------------------------------------------------------------------------
#pragma mark - Interface (NSMutableDictionary + WWTHelper)
//------------------------------------------------------------------------

@interface NSMutableDictionary (WWTHelper)

- (void)wwt_setObject:(id)obj forKey:(id<NSCopying>)key;

- (void)wwt_setTimestampDateObject:(NSDate*)date forKey:(id<NSCopying>)key;


@end
