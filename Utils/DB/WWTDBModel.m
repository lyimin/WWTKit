//
//  WWTDBModel.m
//  WWTKit
//
//  Created by eamon on 2019/4/9.
//  Copyright © 2019年 wewave Inc. All rights reserved.
//

#import "WWTDBModel.h"

#import <objc/runtime.h>

#import "WWTKitMacro.h"

#import "WWTDBHelper.h"



//------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------

//MARK: >> WWTDBDataType
//------------------------------------------------------------------------
WWTDBDataType WWTDBDataType_TEXT    = @"TEXT";
WWTDBDataType WWTDBDataType_INTEGER = @"INTEGER";
WWTDBDataType WWTDBDataType_REAL    = @"REAL";
WWTDBDataType WWTDBDataType_BLOB    = @"BLOB";
WWTDBDataType WWTDBDataType_NULL    = @"NULL";

NSString * const WWTDBPrimaryKey    = @"primary key";
NSString * const WWTDBPrimaryId     = @"primaryKey";


//------------------------------------------------------------------------
#pragma mark - Implementation (WWTDBModel)
//------------------------------------------------------------------------

@implementation WWTDBModel


//------------------------------------------------------------------------
#pragma mark - Initialize
//------------------------------------------------------------------------

+ (void)initialize
{
    if (self != [WWTDBModel self]) {
        [self createTable];
    }
}

- (instancetype)init
{
    if (self = [super init]) {
        
        NSDictionary *dic = [self.class getAllProperties];
        _columeNames = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"name"]];
        _columeTypes = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"type"]];
    }
    return self;
}

//------------------------------------------------------------------------
#pragma mark - Key
//------------------------------------------------------------------------

+ (NSDictionary *)getPropertys
{
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    NSArray *theTransients = [[self class] transients];
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList([self class], &outCount);
    
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        // 获取属性名
        NSString *propertyName = [NSString stringWithCString:property_getName(property) encoding:NSUTF8StringEncoding];
        if ([theTransients containsObject:propertyName]) {
            continue;
        }
        [proNames addObject:propertyName];
        // 获取属性类型等参数
        NSString *propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
      
        if ([propertyType hasPrefix:@"T@\"NSString\""]) {
            [proTypes addObject:WWTDBDataType_TEXT];
        }
        else if ([propertyType hasPrefix:@"T@\"NSData\""]) {
            [proTypes addObject:WWTDBDataType_BLOB];
        }
        else if ([propertyType hasPrefix:@"Ti"] ||
                 [propertyType hasPrefix:@"TI"] ||
                 [propertyType hasPrefix:@"Ts"] ||
                 [propertyType hasPrefix:@"TS"] ||
                 [propertyType hasPrefix:@"TB"] ||
                 [propertyType hasPrefix:@"Tq"] ||
                 [propertyType hasPrefix:@"TQ"]) {
            [proTypes addObject:WWTDBDataType_INTEGER];
        }
        else {
            [proTypes addObject:WWTDBDataType_REAL];
        }
        
    }
    free(properties);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames, @"name", proTypes, @"type", nil];
}

+ (NSDictionary *)getAllProperties
{
    NSDictionary *dict = [self.class getPropertys];
    
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    [proNames addObject:WWTDBPrimaryId];
    [proTypes addObject:[NSString stringWithFormat:@"%@ %@", WWTDBDataType_INTEGER, WWTDBPrimaryKey]];
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

+ (BOOL)isExistInTable
{
    __block BOOL res = NO;
    WWTDBHelper *wwtdb = [WWTDBHelper shareInstance];
    [wwtdb.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        res = [db tableExists:tableName];
    }];
    return res;
}

+ (NSArray *)getColumns
{
    NSMutableArray *columns = [NSMutableArray array];
    WWTDBHelper *wwtdb = [WWTDBHelper shareInstance];
    [wwtdb.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        FMResultSet *resultSet = [db getTableSchema:tableName];
        
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:@"name"];
            [columns addObject:column];
        }
    }];
    return [columns copy];
}

//------------------------------------------------------------------------
#pragma mark - Insert or Update
//------------------------------------------------------------------------

- (BOOL)saveOrUpdate
{
    id primaryValue = [self valueForKey:WWTDBPrimaryId];
    if ([primaryValue intValue] <= 0) {
        return [self save];
    }
    
    return [self update];
}

- (BOOL)saveOrUpdateByColumnName:(NSString*)columnName AndColumnValue:(NSString*)columnValue
{
    id record = [self.class findFirstByCriteria:[NSString stringWithFormat:@"where %@ = %@", columnName, columnValue]];
    if (record) {
        id primaryValue = [record valueForKey:WWTDBPrimaryId]; // 取到了主键PK
        if ([primaryValue intValue] <= 0) {
            return [self save];
        }
        else {
            self.primaryKey = [primaryValue integerValue];
            return [self update];
        }
    }
    else {
        return [self save];
    }
}

- (BOOL)save
{
    NSString *tableName = NSStringFromClass(self.class);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray  array];
    
    for (int i = 0; i < self.columeNames.count; i++) {
        NSString *proname = [self.columeNames objectAtIndex:i];
        if ([proname isEqualToString:WWTDBPrimaryId]) {
            continue;
        }
        [keyString appendFormat:@"%@,", proname];
        [valueString appendString:@"?,"];
        id value = [self valueForKey:proname];
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
    
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
    
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
        res = [db executeUpdate:sql withArgumentsInArray:insertValues];
        self.primaryKey = res ? [NSNumber numberWithLongLong : db.lastInsertRowId].intValue:0;
        WWTLog(res ? @"wwtdb: 插入成功" : @"wwtdb: 插入失败");
    }];
    return res;
}

+ (BOOL)saveObjects:(NSArray *)array
{
    // 判断是否是JKBaseModel的子类
    for (WWTDBModel *model in array) {
        if (![model isKindOfClass:[WWTDBModel class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    
    // 如果要支持事务
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (WWTDBModel *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            NSMutableString *keyString = [NSMutableString string];
            NSMutableString *valueString = [NSMutableString string];
            NSMutableArray *insertValues = [NSMutableArray  array];
            
            for (int i = 0; i < model.columeNames.count; i++) {
                NSString *proname = [model.columeNames objectAtIndex:i];
                if ([proname isEqualToString:WWTDBPrimaryId]) {
                    continue;
                }
                [keyString appendFormat:@"%@,", proname];
                [valueString appendString:@"?,"];
                id value = [model valueForKey:proname];
                if (!value) {
                    value = @"";
                }
                [insertValues addObject:value];
            }
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            [valueString deleteCharactersInRange:NSMakeRange(valueString.length - 1, 1)];
            
            NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@);", tableName, keyString, valueString];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:insertValues];
            model.primaryKey = flag ? [NSNumber numberWithLongLong : db.lastInsertRowId].intValue:0;
            WWTLog(flag ? @"wwtdb:插入成功" : @"wwtdb:插入失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}


/** 更新单个对象 */
- (BOOL)update
{
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:WWTDBPrimaryId];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSMutableString *keyString = [NSMutableString string];
        NSMutableArray *updateValues = [NSMutableArray  array];
        for (int i = 0; i < self.columeNames.count; i++) {
            NSString *proname = [self.columeNames objectAtIndex:i];
            if ([proname isEqualToString:WWTDBPrimaryId]) {
                continue;
            }
            [keyString appendFormat:@" %@=?,", proname];
            id value = [self valueForKey:proname];
            if (!value) {
                value = @"";
            }
            [updateValues addObject:value];
        }
        
        //删除最后那个逗号
        [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?;", tableName, keyString, WWTDBPrimaryId];
        [updateValues addObject:primaryValue];
        res = [db executeUpdate:sql withArgumentsInArray:updateValues];
        WWTLog(res ? @"wwtdb:更新成功" : @"wwtdb:更新失败");
    }];
    return res;
}

+ (BOOL)updateObjects:(NSArray *)array
{
    for (WWTDBModel *model in array) {
        if (![model isKindOfClass:[WWTDBModel class]]) {
            return NO;
        }
    }
    __block BOOL res = YES;
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    
    // 如果要支持事务
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (WWTDBModel *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:WWTDBPrimaryId];
            if (!primaryValue || primaryValue <= 0) {
                res = NO;
                *rollback = YES;
                return;
            }
            
            NSMutableString *keyString = [NSMutableString string];
            NSMutableArray *updateValues = [NSMutableArray array];
            for (int i = 0; i < model.columeNames.count; i++) {
                NSString *proname = [model.columeNames objectAtIndex:i];
                if ([proname isEqualToString:WWTDBPrimaryId]) {
                    continue;
                }
                [keyString appendFormat:@" %@=?,", proname];
                id value = [model valueForKey:proname];
                if (!value) {
                    value = @"";
                }
                [updateValues addObject:value];
            }
            
            //删除最后那个逗号
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@=?;", tableName, keyString, WWTDBPrimaryId];
            [updateValues addObject:primaryValue];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:updateValues];
            WWTLog(flag ? @"更新成功" : @"更新失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    
    return res;
}

//------------------------------------------------------------------------
#pragma mark - Delete
//------------------------------------------------------------------------

- (BOOL)deleteObject
{
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:WWTDBPrimaryId];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?", tableName, WWTDBPrimaryId];
        res = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
        WWTLog(res ? @"wwtdb:删除成功" : @"删除失败");
    }];
    return res;
}

/** 批量删除用户对象 */
+ (BOOL)deleteObjects:(NSArray *)array
{
    for (WWTDBModel *model in array) {
        if (![model isKindOfClass:[WWTDBModel class]]) {
            return NO;
        }
    }
    
    __block BOOL res = YES;
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    // 如果要支持事务
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (WWTDBModel *model in array) {
            NSString *tableName = NSStringFromClass(model.class);
            id primaryValue = [model valueForKey:WWTDBPrimaryId];
            if (!primaryValue || primaryValue <= 0) {
                return ;
            }
            
            NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,WWTDBPrimaryId];
            BOOL flag = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
            WWTLog(flag ? @"wwt:删除成功" : @"wwt:删除失败");
            if (!flag) {
                res = NO;
                *rollback = YES;
                return;
            }
        }
    }];
    return res;
}

+ (BOOL)deleteObjectsByCriteria:(NSString *)criteria{
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ %@ ", tableName, criteria];
        res = [db executeUpdate:sql];
        WWTLog(res ? @"wwt:删除成功" : @"wwt:删除失败");
    }];
    return res;
}

+ (BOOL)deleteObjectsWithFormat:(NSString *)format, ...
{
    va_list ap;
    va_start(ap, format);
    NSString *criteria = [[NSString alloc] initWithFormat:format locale:[NSLocale currentLocale] arguments:ap];
    va_end(ap);
    
    return [self deleteObjectsByCriteria:criteria];
}

//------------------------------------------------------------------------
#pragma mark - Find
//------------------------------------------------------------------------

+ (NSArray *)findAll
{
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    NSMutableArray *users = [NSMutableArray array];
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        
        while ([resultSet next]) {
            WWTDBModel *model = [[self.class alloc] init];
            for (int i = 0; i < model.columeNames.count; i++) {
                NSString *columeName = [model.columeNames objectAtIndex:i];
                NSString *columeType = [model.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:WWTDBDataType_TEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                }
                else if ([columeType isEqualToString:WWTDBDataType_BLOB]) {
                    [model setValue:[resultSet dataForColumn:columeName] forKey:columeName];
                }
                else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return users;
}

+ (instancetype)findFirstByCriteria:(NSString *)criteria
{
    NSArray *results = [self.class findByCriteria:criteria];
    if (results.count < 1) {
        return nil;
    }
    
    return [results firstObject];
}

+ (instancetype)findByPK:(int)inPk
{
    NSString *condition = [NSString stringWithFormat:@"WHERE %@=%d", WWTDBPrimaryId, inPk];
    return [self findFirstByCriteria:condition];
}

+ (NSArray *)findByCriteria:(NSString *)criteria
{
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    NSMutableArray *users = [NSMutableArray array];
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@ %@", tableName, criteria];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            WWTDBModel *model = [[self.class alloc] init];
            for (int i = 0; i < model.columeNames.count; i++) {
                NSString *columeName = [model.columeNames objectAtIndex:i];
                NSString *columeType = [model.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:WWTDBDataType_TEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                }
                else if ([columeType isEqualToString:WWTDBDataType_BLOB]) {
                    [model setValue:[resultSet dataForColumn:columeName] forKey:columeName];
                }
                else {
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [users addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return users;
}

//------------------------------------------------------------------------
#pragma mark - Table
//------------------------------------------------------------------------

+ (BOOL)clearTable
{
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@",tableName];
        res = [db executeUpdate:sql];
        WWTLog(res ? @"清空成功" : @"清空失败");
    }];
    return res;
}

+ (BOOL)createTable
{
    __block BOOL res = YES;
    WWTDBHelper *helper = [WWTDBHelper shareInstance];
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *columeAndType = [self.class getColumeAndTypeString];
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);", tableName, columeAndType];
        if (![db executeUpdate:sql]) {
            res = NO;
            *rollback = YES;
            return;
        }
        
        NSMutableArray *columns = [NSMutableArray array];
        FMResultSet *resultSet = [db getTableSchema:tableName];
        while ([resultSet next]) {
            NSString *column = [resultSet stringForColumn:@"name"];
            [columns addObject:column];
        }
        NSDictionary *dict = [self.class getAllProperties];
        NSArray *properties = [dict objectForKey:@"name"];
        NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
        // 过滤数组
        NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
        for (NSString *column in resultArray) {
            NSUInteger index = [properties indexOfObject:column];
            NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
            NSString *fieldSql = [NSString stringWithFormat:@"%@ %@", column, proType];
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ", NSStringFromClass(self.class), fieldSql];
            if (![db executeUpdate:sql]) {
                res = NO;
                *rollback = YES;
                return ;
            }
        }
    }];
    
    return res;
}

//------------------------------------------------------------------------
#pragma mark - must be override method
//------------------------------------------------------------------------

+ (NSArray *)transients
{
    return [NSArray array];
}

//------------------------------------------------------------------------
#pragma mark - Private Methods
//------------------------------------------------------------------------

+ (NSString *)getColumeAndTypeString
{
    NSMutableString *pars = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    NSMutableArray *proTypes = [dict objectForKey:@"type"];
    
    for (int i = 0; i < proNames.count; i++) {
        [pars appendFormat:@"%@ %@", [proNames objectAtIndex:i], [proTypes objectAtIndex:i]];
        if(proNames.count != i+1) {
            [pars appendString:@","];
        }
    }
    return pars;
}


@end
