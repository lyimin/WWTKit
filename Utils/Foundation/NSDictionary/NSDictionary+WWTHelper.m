//
//  NSDictionary+WWTHelper.m
//  WWTKit
//
//  Created by eamon on 2019/4/2.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import "NSDictionary+WWTHelper.h"



//------------------------------------------------------------------------
#pragma mark - Implementation (NSDictionary + WWTHelper)
//------------------------------------------------------------------------

@implementation NSDictionary (WWTHelper)


+ (NSDictionary *)wwt_dictionaryFromJsonString:(NSString *)jsonString
{
    if (!jsonString) {
        return nil;
    }
    
    if (![jsonString isKindOfClass:NSString.class]) {
        NSCParameterAssert(NO);
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        //MLLog(@"json解析失败(ml_dictionaryFromJsonString): %@",err);
        return nil;
    }
    
    return dic;
}

+ (NSString *)wwt_stringFromJsonDictionary:(NSDictionary *)jsonDictionary
{
    if (!jsonDictionary) {
        return nil;
    }
    
    if (![jsonDictionary isKindOfClass:NSDictionary.class]) {
        NSCParameterAssert(NO);
        return nil;
    }
    
    NSError *err;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonDictionary
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&err];
    
    if(err) {
        //MLLog(@"json解析失败(ml_stringFromJsonDictionary): %@",err);
        return nil;
    }
    
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSString *)wwt_JSONString
{
    if (wwt_emptyDict(self)) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    }
    
    NSString *jsonstr = [[NSString alloc] initWithData:jsondata encoding:NSUTF8StringEncoding];
    return jsonstr;
}


- (NSData *)wwt_JSONData
{
    if (wwt_emptyDict(self)) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        return nil;
    }
    
    return jsonData;
}


@end


//------------------------------------------------------------------------
#pragma mark - Implementation (NSMutableDictionary + WWTHelper)
//------------------------------------------------------------------------

@implementation NSMutableDictionary (WWTHelper)

- (void)wwt_setObject:(id)obj forKey:(id<NSCopying>)key
{
    if (!obj || !key) {
        return;
    }
    
    [self setObject:obj forKey:key];
}

- (void)wwt_setTimestampDateObject:(NSDate *)date forKey:(id<NSCopying>)key
{
    if (!date || !key) {
        return;
    }
    
    NSTimeInterval interval = [date timeIntervalSince1970];
    [self setObject:@(interval) forKey:key];
}


@end
