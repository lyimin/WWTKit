//
//  WWTDBHelper.m
//  WWTKit
//
//  Created by eamon on 2019/4/9.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import "WWTDBHelper.h"

#import <objc/runtime.h>

#import "WWTFileManager.h"

#import "WWTDBHelper.h"
#import "WWTDBModel.h"





//------------------------------------------------------------------------
#pragma mark - Interface (WWTDBHelper)
//------------------------------------------------------------------------

@interface WWTDBHelper ()

@property (nonatomic, retain) FMDatabaseQueue *dbQueue;


@end



//------------------------------------------------------------------------
#pragma mark - Implementation (WWTDBHelper)
//------------------------------------------------------------------------

@implementation WWTDBHelper


static WWTDBHelper *_helper;

+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _helper = [[WWTDBHelper alloc] init];
    });
    return _helper;
}

+ (NSString *)dbPathWithDirectoryName:(NSString *)directoryName
{
    NSString *docsdir = [WWTFileManager documentsPath];
    
    if (directoryName == nil || directoryName.length == 0) {
        docsdir = [docsdir stringByAppendingPathComponent:@"DB"];
    } else {
        docsdir = [docsdir stringByAppendingPathComponent:directoryName];
    }
    if (![WWTFileManager fileExistAtPath:docsdir]) {
        [WWTFileManager createDirectoryAtPath:docsdir];
    }
    NSString *dbpath = [docsdir stringByAppendingPathComponent:@"wwtdb.sqlite"];
    return dbpath;
}

- (BOOL)changeDBWithDirectoryName:(NSString *)directoryName
{
    if (_helper.dbQueue) {
        _helper.dbQueue = nil;
    }
    self.dbQueue = [[FMDatabaseQueue alloc] initWithPath:[self.class dbPathWithDirectoryName:directoryName]];
    
    int numClasses;
    Class *classes = NULL;
    numClasses = objc_getClassList(NULL,0);
    
    if (numClasses > 0) {
        classes = (__unsafe_unretained Class *)malloc(sizeof(Class) * numClasses);
        numClasses = objc_getClassList(classes, numClasses);
        for (int i = 0; i < numClasses; i++) {
            if (class_getSuperclass(classes[i]) == [WWTDBModel class]){
                id class = classes[i];
                [class performSelector:@selector(createTable) withObject:nil];
            }
        }
        free(classes);
    }
    return YES;
}

//------------------------------------------------------------------------
#pragma mark - Getter | Setter
//------------------------------------------------------------------------

+ (NSString *)dbPath
{
    return [self dbPathWithDirectoryName:nil];
}

- (FMDatabaseQueue *)dbQueue
{
    if (_dbQueue == nil) {
        
        _dbQueue = [[FMDatabaseQueue alloc] initWithPath:[self.class dbPath]];
    }
    return _dbQueue;
}

@end
