//
//  NSData+WWTHelper.m
//  WWTKit
//
//  Created by eamon on 2019/4/3.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import "NSData+WWTHelper.h"



//------------------------------------------------------------------------
#pragma mark - Implementation (NSData + WWTHelper)
//------------------------------------------------------------------------

@implementation NSData (WWTHelper)


- (NSDictionary *)wwt_toDictionary
{
    if (!self) {
        return nil;
    }
    
    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:self options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        return nil;
    }
    return dic;
}


@end
