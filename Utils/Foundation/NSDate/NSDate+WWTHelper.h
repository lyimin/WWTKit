//
//  NSDate+WWTHelper.h
//  WWTKit
//
//  Created by EamonLiang on 2019/4/14.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import <Foundation/Foundation.h>



//------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------

//MARK: >> Format
//------------------------------------------------------------------------
typedef NSString* WWTDateHelperFormat;

// "20160520" --> 2016.05.20
extern WWTDateHelperFormat const WWTDateHelperFormat_YYYYMMDD;
// "1530" --> 15:30
extern WWTDateHelperFormat const WWTDateHelperFormat_HHmm;
// "201605201530" --> 2016.05.20 15:30
extern WWTDateHelperFormat const WWTDateHelperFormat_YYYYMMDDHHmm;
// "20160520153013" --> 2016.05.20 15:30:13
extern WWTDateHelperFormat const WWTDateHelperFormat_YYYYMMDDHHmmss;

//MARK: >> Seconds
//------------------------------------------------------------------------
extern const NSTimeInterval WWTDASecond;
extern const NSTimeInterval WWTDAMinute;
extern const NSTimeInterval WWTDAHour;
extern const NSTimeInterval WWTDADay;
extern const NSTimeInterval WWTDAWeek;
extern const NSTimeInterval WWTDAYear;


//------------------------------------------------------------------------
#pragma mark - Interface (NSDate + WWTHelper)
//------------------------------------------------------------------------

@interface NSDate (WWTHelper)


//------------------------------------------------------------------------
#pragma mark - Calendar
//------------------------------------------------------------------------

/**
 构建日历, identifier:Gregorian  local: 'en_US'
 
 @return NSCalendar
 */
+ (NSCalendar *)calendar;


//------------------------------------------------------------------------
#pragma mark - Date
//------------------------------------------------------------------------


/**
 根据年月日构建00:00时间
 */
+ (NSDate *)dateInYear:(int)year month:(int)month day:(int)day;


/**
 根据年与日时分秒构建时间
 */
+ (NSDate *)dateInYear:(int)year month:(int)month day:(int)day
                  hour:(int)hour min:(int)min sec:(int)sec;

+ (NSDate *)dateWithJSONIntValueWithNSDictionary:(NSDictionary*)dict withKey:(NSString*)key;
+ (NSDate *)dateWithJSONDoubleValueWithNSDictionary:(NSDictionary *)dict withKey:(NSString *)key;

//------------------------------------------------------------------------
#pragma mark - Offset
//------------------------------------------------------------------------

- (NSDate *)dateByYearOffset:(int)offset;  // 返回年偏移后时间
- (NSDate *)dateByMonthOffset:(int)offset; // 返回月偏移后时间
- (NSDate *)dateByDayOffset:(int)offset;   // 返回日偏移后时间

- (NSDate *)yesterday;         // 偏移到下一天
- (NSDate *)tomorrow;          // 偏移到前一天
- (NSDate *)lastYear;          // 偏移到下一年
- (NSDate *)nextYear;          // 偏移到上一年
- (NSDate *)lastMonth;         // 偏移到上一月
- (NSDate *)nextMonth;         // 偏移到下一月
- (NSDate *)lastWeek;          // 偏移到上一周
- (NSDate *)nextWeek;          // 偏移到下一周
- (NSDate *)beginningOfDay;    // 偏移到00:00
- (NSDate *)endingOfDay;       // 偏移到23:59
- (NSDate *)beginningOfWeek;   // 偏移到本周第一天(周日)00:00
- (NSDate *)endingOfWeek;      // 偏移到本周最后一天(周六)23:59
- (NSDate *)beginningOfMonth;  // 偏移到本月第一天00:00
- (NSDate *)endingOfMonth;     // 偏移到本月最后一天23:59


//------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------

- (int)year;       // 年
- (int)month;      // 月
- (int)day;        // 日
- (int)hour;       // 时
- (int)minute;     // 分
- (int)dayOfWeek;  // 0:周日 1:周一 ... 6:周六


//------------------------------------------------------------------------
#pragma mark - Compare Utils
//------------------------------------------------------------------------

/**
 返回时间的天数偏移值.
 
 @param date NSDate
 @return offset
 */
- (int)dayOffsetWithDate:(NSDate *)date;

/**
 是否比date早
 
 @param date NSDate
 @return BOOL
 */
- (BOOL)isEarlierThan:(NSDate *)date;

/**
 是否比date晚
 
 @param date NSDate
 @return BOOL
 */
- (BOOL)isLaterThan:(NSDate *)date;

/*!
 *  判断date是否在 start_time与end_time两字符串描述的时间内(24小时制, 包含边界)
 *
 *  @param start_time 开始时间 string 格式"HH:mm:ss" 例如:"23:12:23"
 *  @param end_time   结束时间 string 格式"HH:mm:ss" 例如:"05:11:11"
 *
 *  @return 是否在区间内(包含边界)
 */
- (BOOL)isBetween:(NSString *)start_time to:(NSString *)end_time;

/*!
 *  判断两个date是否处于同一天
 *
 *  @param date second date
 *
 *  @return BOOL
 */
- (BOOL)isCloseTo:(NSDate *)date;

/*!
 *  判断两个date是否间隔在n秒内
 *
 *  @param date second date
 *  @param nSeconds Time Interval
 *
 *  @return BOOL
 */
- (BOOL)isCloseTo:(NSDate *)date within:(NSTimeInterval) nSeconds;

//------------------------------------------------------------------------
#pragma mark - Date Utils
//------------------------------------------------------------------------

/**
 根据时间字符串和时间格式字符串, 创建NSDate.
 
 @param str    时间字符串
 @param format 时间格式字符串
 @return NSDate
 */
+ (NSDate *)dateWithString:(NSString *)str inFormat:(NSString *)format;


/**
 根据时间字符串, 创建NSDate.
 格式为: @"08:05"
 
 @param str 时间字符串 NSString
 @return NSDate
 */
+ (NSDate *)timeDateWithString:(NSString *)str;

/**
 根据时间字符串, 创建NSDate.
 格式为: @"08:05"
 如果传入时间已过, 则返回下一次时间
 
 @param str 时间字符串 NSString
 @return NSDate
 */
+ (NSDate *)nextTimeDateWithString:(NSString *)str;


//------------------------------------------------------------------------
#pragma mark - String Utils
//------------------------------------------------------------------------

/**
 *  时间格式字符串
 *
 *  @param format NSString
 *
 *  @return NSString
 */
- (NSString *)dateStringWithFormat:(NSString *)format;

/**
 *  本地时间格式字符串. 例如在国内地区, 会返回"周三"等字符串.
 *
 *  @param format NSString
 *
 *  @return NSString
 */
- (NSString *)l10nDateStringWithFormat:(NSString *)format;

/**
 国际时间格式字符串. 在所有读取, 都会返回"Sun"等字符串.
 
 @param format NSString
 @return NSString
 */
- (NSString *)i18nDateStringWithFormat:(NSString *)format;


//------------------------------------------------------------------------
#pragma mark - array util
//------------------------------------------------------------------------

/*
 *  获取两个日期直接的NSDate（包含start，不包含end）
 */
+ (NSArray *)getDatesInBetween:(NSDate *)startDate to:(NSDate *)endDate;


@end
