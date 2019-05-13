//
//  WWTDBHelper.h
//  WWTKit
//
//  Created by eamon on 2019/4/9.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <FMDB/FMDB.h>



//------------------------------------------------------------------------
#pragma mark - Interface (WWTDBHelper)
//------------------------------------------------------------------------

@interface WWTDBHelper : NSObject

/// 数据库操作队列
@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;



//------------------------------------------------------------------------
#pragma mark - Methods
//------------------------------------------------------------------------

+ (instancetype)shareInstance;

/**
 返回数据库保存在沙盒的路径
 */
+ (NSString *)dbPath;

- (BOOL)changeDBWithDirectoryName:(NSString *)directoryName;


@end
