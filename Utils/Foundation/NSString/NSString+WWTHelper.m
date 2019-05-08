//
//  NSString+WWTHelper.m
//  WWTKit
//
//  Created by eamon on 2019/4/3.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import "NSString+WWTHelper.h"

#import "NSData+WWTHelper.h"



//------------------------------------------------------------------------
#pragma mark - Implementation (NSString + WWTHelper)
//------------------------------------------------------------------------

@implementation NSString (WWTHelper)


- (NSDictionary *)wwt_toDictionary
{
    if (wwt_emptyStr(self)) {
        return nil;
    }
    
    return [[self dataUsingEncoding:NSUTF8StringEncoding] wwt_toDictionary];
}


@end
