//
//  NSArray+WWTHelper.m
//  WWTKit
//
//  Created by EamonLiang on 2019/4/29.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import "NSArray+WWTHelper.h"



//------------------------------------------------------------------------
#pragma mark - Implementation (NSArray + WWTHelper)
//------------------------------------------------------------------------

@implementation NSArray (WWTHelper)


- (NSArray *)groupWithCount:(NSInteger)count
{
    NSInteger all = self.count;
    if (count == 0) {
        return @[];
    }
    
    NSMutableArray *temp = @[].mutableCopy;
    int i = 0;
    while(all) {
        NSRange range = NSMakeRange(i, MIN(count, all));
        NSArray *subArr = [self subarrayWithRange:range];
        [temp addObject:subArr];
        all -= range.length;
        i += range.length;
    }
    return temp;
}


@end
