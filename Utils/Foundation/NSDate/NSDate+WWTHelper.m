//
//  NSDate+WWTHelper.m
//  WWTKit
//
//  Created by EamonLiang on 2019/4/14.
//  Copyright © 2019 wewave Inc. All rights reserved.
//

#import "NSDate+WWTHelper.h"


//------------------------------------------------------------------------
#pragma mark - Constants
//------------------------------------------------------------------------

//MARK: >> Format
//------------------------------------------------------------------------
WWTDateHelperFormat const WWTDateHelperFormat_YYYYMMDD       = @"yyyyMMdd";
WWTDateHelperFormat const WWTDateHelperFormat_HHmm           = @"HHmm";
WWTDateHelperFormat const WWTDateHelperFormat_YYYYMMDDHHmm   = @"yyyyMMddHHmm";
WWTDateHelperFormat const WWTDateHelperFormat_YYYYMMDDHHmmss = @"yyyyMMddHHmmss";


//MARK: >> Seconds
//------------------------------------------------------------------------
const NSTimeInterval WWTDASecond = 1;
const NSTimeInterval WWTDAMinute = 60;
const NSTimeInterval WWTDAHour   = 3600;
const NSTimeInterval WWTDADay    = 86400;
const NSTimeInterval WWTDAWeek   = 604800;
const NSTimeInterval WWTDAYear   = 31556926; // As Google says

//------------------------------------------------------------------------
#pragma mark - Implementation (NSDate + WWTHelper)
//------------------------------------------------------------------------

@implementation NSDate (WWTHelper)


//------------------------------------------------------------------------
#pragma mark - Locale
//------------------------------------------------------------------------

+ (NSLocale *)i18nLocale
{
    return [NSLocale localeWithLocaleIdentifier:@"en_US"];
}

+ (NSLocale *)l10nLocale
{
    return [NSLocale systemLocale];
}

//------------------------------------------------------------------------
#pragma mark - Calendar
//------------------------------------------------------------------------

+ (NSCalendar *)i18nCalendar
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.locale = [self i18nLocale];
    return calendar;
}

+ (NSCalendar *)l10nCalendar
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.locale = [self l10nLocale];
    return calendar;
}

+ (NSCalendar *)calendar
{
    return [self i18nCalendar];
}


//------------------------------------------------------------------------
#pragma mark - Date
//------------------------------------------------------------------------

+ (NSDate *)dateInYear:(int)year month:(int)month day:(int)day
{
    NSCalendarUnit units = (NSCalendarUnitYear | NSCalendarUnitMonth |
                            NSCalendarUnitDay | NSCalendarUnitHour |
                            NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    NSCalendar *calendar = [NSDate calendar];
    NSDateComponents *components = [calendar components:units fromDate:[NSDate date]];
    components.year   = year;
    components.month  = month;
    components.day    = day;
    components.hour   = 0;
    components.minute = 0;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
}

+ (NSDate *)dateInYear:(int)year month:(int)month day:(int)day
                  hour:(int)hour min:(int)min sec:(int)sec
{
    NSCalendarUnit units = (NSCalendarUnitYear | NSCalendarUnitMonth |
                            NSCalendarUnitDay | NSCalendarUnitHour |
                            NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    NSCalendar *calendar = [NSDate calendar];
    NSDateComponents *components = [calendar components:units fromDate:[NSDate date]];
    components.year   = year;
    components.month  = month;
    components.day    = day;
    components.hour   = hour;
    components.minute = min;
    components.second = sec;
    
    return [calendar dateFromComponents:components];
}

+ (NSDate *)dateWithJSONIntValueWithNSDictionary:(NSDictionary *)dict withKey:(NSString *)key
{
    NSInteger value = [[dict valueForKey:key] integerValue];
    return [NSDate dateWithTimeIntervalSince1970:value];
}

+ (NSDate *)dateWithJSONDoubleValueWithNSDictionary:(NSDictionary *)dict withKey:(NSString *)key
{
    NSTimeInterval value = [[dict valueForKey:key] doubleValue];
    return [NSDate dateWithTimeIntervalSince1970:value];
}


//------------------------------------------------------------------------
#pragma mark - Offset
//------------------------------------------------------------------------

- (NSDate *)dateByYearOffset:(int)offset
{
    if (offset == 0) {
        return self;
    }
    
    NSCalendar *calendar = [NSDate calendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self];
    [components setYear:offset];
    
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:NSCalendarMatchStrictly];
    return date;
}

- (NSDate *)dateByMonthOffset:(int)offset
{
    if (offset == 0) {
        return self;
    }
    
    NSCalendar *calendar = [NSDate calendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self];
    [components setMonth:offset];
    
    NSDate *date = [calendar dateByAddingComponents:components toDate:self options:NSCalendarMatchStrictly];
    return date;
}

- (NSDate *)dateByDayOffset:(int)offset
{
    if (offset == 0) {
        return self;
    }
    
    NSCalendar *calendar = [NSDate calendar];
    NSDateComponents *compenents = [calendar components:NSCalendarUnitDay fromDate:self];
    [compenents setDay:offset];
    
    NSDate *date = [calendar dateByAddingComponents:compenents toDate:self options:NSCalendarMatchStrictly];
    return date;
}

- (NSDate *)yesterday
{
    NSDate *yesterday = [self dateByDayOffset:-1];
    return yesterday;
}

- (NSDate *)tomorrow
{
    NSDate *tomorrow = [self dateByDayOffset:1];
    return tomorrow;
}

- (NSDate *)lastYear
{
    NSDate *last_year = [self dateByYearOffset:-1];
    return last_year;
}

- (NSDate *)nextYear
{
    NSDate *next_year = [self dateByYearOffset:1];
    return next_year;
}

- (NSDate *)lastMonth
{
    NSDate *last_month = [self dateByMonthOffset:-1];
    return last_month;
}

- (NSDate *)nextMonth
{
    NSDate *next_month = [self dateByMonthOffset:1];
    return next_month;
}

- (NSDate *)lastWeek
{
    NSDate *last_week = [self dateByDayOffset:-7];
    return last_week;
}

- (NSDate *)nextWeek
{
    NSDate *next_week = [self dateByDayOffset:7];
    return next_week;
}

- (NSDate *)beginningOfDay
{
    NSCalendarUnit units = (NSCalendarUnitYear | NSCalendarUnitMonth |
                            NSCalendarUnitDay | NSCalendarUnitHour |
                            NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    NSCalendar *calendar = [NSDate i18nCalendar];
    NSDateComponents *components = [calendar components:units fromDate:self];
    components.hour   = 0;
    components.minute = 0;
    components.second = 0;
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)endingOfDay
{
    NSCalendarUnit units = (NSCalendarUnitYear | NSCalendarUnitMonth |
                            NSCalendarUnitDay | NSCalendarUnitHour |
                            NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    NSCalendar *calendar = [NSDate i18nCalendar];
    NSDateComponents *components = [calendar components:units fromDate:self];
    components.hour   = 23;
    components.minute = 59;
    components.second = 59;
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)beginningOfWeek
{
    int offset = [self dayOfWeek];
    return [[self dateByDayOffset:-(offset)] beginningOfDay];
}

- (NSDate *)endingOfWeek
{
    return [[[[self nextWeek] beginningOfWeek] dateByDayOffset:-1] endingOfDay];
}

- (NSDate *)beginningOfMonth
{
    int offset = [self day];
    return [[self dateByDayOffset:-(offset-1)] beginningOfDay];
}

- (NSDate *)endingOfMonth
{
    return [[[[self nextMonth] beginningOfMonth] dateByDayOffset:-1] endingOfDay];
}


//------------------------------------------------------------------------
#pragma mark - Properties
//------------------------------------------------------------------------

- (int)year
{
    NSCalendar *calendar = [NSDate i18nCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self];
    return (int)components.year;
}

- (int)month
{
    NSCalendar *calendar = [NSDate i18nCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMonth fromDate:self];
    return (int)components.month;
}

- (int)day
{
    NSCalendar *calendar = [NSDate i18nCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:self];
    return (int)components.day;
}

- (int)hour
{
    NSCalendar *calendar = [NSDate i18nCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitHour fromDate:self];
    return (int)components.hour;
}

- (int)minute
{
    NSCalendar *calendar = [NSDate i18nCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitMinute fromDate:self];
    return (int)components.minute;
}

- (int)dayOfWeek
{
    NSCalendar *calendar = [NSDate i18nCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitWeekday fromDate:self];
    NSInteger dayOfWeek = [components weekday];  // 1 is Sunday
    return (int)dayOfWeek - 1;  // 0 is Sunday
}

//------------------------------------------------------------------------
#pragma mark - Compare
//------------------------------------------------------------------------

- (int)dayOffsetWithDate:(NSDate *)date
{
    NSCalendar *calendar = [NSDate calendar];
    NSDateComponents *compenents = [calendar components:NSCalendarUnitDay fromDate:self toDate:date options:0];
    return (int)compenents.day;
}

- (BOOL)isEarlierThan:(NSDate *)date
{
    return ([self compare:date] == NSOrderedAscending);
}

- (BOOL)isLaterThan:(NSDate *)date
{
    return ([self compare:date] == NSOrderedDescending);
}

- (BOOL)isBetween:(NSString *)start_time to:(NSString *)end_time
{
    if (!self || !start_time || !end_time) {
        return NO;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"HH:mm:ss";
    
    NSString *value_time = [formatter stringFromDate:self];
    
    NSDate *start_date = [formatter dateFromString:start_time];
    NSDate *end_date   = [formatter dateFromString:end_time];
    NSDate *value_date = [formatter dateFromString:value_time];
    
    BOOL over_day = NO;
    if ([start_date compare:end_date] == NSOrderedDescending) {
        over_day = YES;
    }
    
    if (!over_day) {
        if ([value_date compare:start_date] == NSOrderedAscending) {
            return NO;
        }
        else if ([value_date compare:end_date] == NSOrderedDescending) {
            return NO;
        }
        else {
            return YES;
        }
    }
    else {
        NSComparisonResult vsc = [value_date compare:start_date];
        if (vsc == NSOrderedDescending || vsc == NSOrderedSame) {
            return YES;
        }
        
        NSComparisonResult vec = [value_date compare:end_date];
        if (vec == NSOrderedAscending || vec == NSOrderedSame) {
            return YES;
        }
        
        return NO;
    }
}

- (BOOL)isCloseTo:(NSDate *)date
{
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    
    int day1 = (int)([self timeIntervalSince1970] + timezoneFix) / (24 * 60 * 60);
    int day2 = (int)([date timeIntervalSince1970] + timezoneFix) / (24 * 60 * 60);
    
    if ((day1 - day2) == 0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isCloseTo:(NSDate *)date within:(NSTimeInterval) nSeconds
{
    
    int date1 = (int)([self timeIntervalSince1970]);
    int date2 = (int)([date timeIntervalSince1970]);
    
    if (abs(date1-date2) < nSeconds) {
        return YES;
    }
    
    return NO;
}


//------------------------------------------------------------------------
#pragma mark - Date Utils
//------------------------------------------------------------------------

+ (NSDate *)dateWithString:(NSString *)str inFormat:(NSString *)format
{
    if (!str || !format) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setCalendar:[NSDate l10nCalendar]];
    [formatter setLocale:[NSDate l10nLocale]];
    
    NSDate *date = [formatter dateFromString:str];
    return date;
}

+ (NSDate *)timeDateWithString:(NSString *)str
{
    // check
    if (!str) {
        return nil;
    }
    
    NSArray *arr = [str componentsSeparatedByString:@":"];
    if (!arr || arr.count != 2) {
        return nil;
    }
    
    NSInteger hour = [arr[0] integerValue];
    NSInteger min  = [arr[1] integerValue];
    if (hour < 0 || min < 0) {
        return nil;
    }
    
    // calculate
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSDate i18nCalendar];
    
    NSCalendarUnit unit =
    (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
     NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    NSDateComponents *components = [calendar components:unit fromDate:now];
    components.hour   = hour;
    components.minute = min;
    components.second = 0;
    
    NSDate *date = [calendar dateFromComponents:components];
    return date;
}

+ (NSDate *)nextTimeDateWithString:(NSString *)str
{
    // check
    if (!str) {
        return nil;
    }
    
    NSArray *arr = [str componentsSeparatedByString:@":"];
    if (!arr || arr.count != 2) {
        return nil;
    }
    
    NSInteger hour = [arr[0] integerValue];
    NSInteger min  = [arr[1] integerValue];
    if (hour < 0 || min < 0) {
        return nil;
    }
    
    // calculate
    NSDate *now = [NSDate date];
    NSCalendar *calendar = [NSDate i18nCalendar];
    
    NSCalendarUnit unit =
    (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
     NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond);
    
    NSDateComponents *components = [calendar components:unit fromDate:now];
    components.hour   = hour;
    components.minute = min;
    components.second = 0;
    
    NSDate *future = [calendar dateFromComponents:components];
    if ([future timeIntervalSinceDate:now] < 0) {
        components.day += 1;
        future = [calendar dateFromComponents:components];
    }
    return future;
}

//------------------------------------------------------------------------
#pragma mark - String Utils
//------------------------------------------------------------------------

- (NSString *)dateStringWithFormat:(NSString *)format
{
    if (!format) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setCalendar:[NSDate calendar]];
    
    NSString *string = [formatter stringFromDate:self];
    return string;
}

- (NSString *)l10nDateStringWithFormat:(NSString *)format
{
    if (!format) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setCalendar:[NSDate l10nCalendar]];
    [formatter setLocale:[NSDate l10nLocale]];
    
    NSString *string = [formatter stringFromDate:self];
    return string;
}

- (NSString *)i18nDateStringWithFormat:(NSString *)format
{
    if (!format) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setCalendar:[NSDate i18nCalendar]];
    [formatter setLocale:[NSDate i18nLocale]];
    
    NSString *string = [formatter stringFromDate:self];
    return string;
}

//------------------------------------------------------------------------
#pragma mark - array util
//------------------------------------------------------------------------

+ (NSArray *)getDatesInBetween:(NSDate *)startDate to:(NSDate *)endDate
{
    NSMutableArray *dates = [@[startDate] mutableCopy];
    
    NSDate *date = [startDate tomorrow];
    
    while (![date isCloseTo:endDate]) {
        [dates addObject:date];
        date = [date tomorrow];
    }
    
    return dates;
}


@end
