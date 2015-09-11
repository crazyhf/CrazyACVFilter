//
//  CrazyLogUtil.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyLogUtil.h"

#import <pthread/pthread.h>

@implementation CrazyLogContent

@end

@implementation CrazyLogUtil

+ (void)debug:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5)
{
    va_list arg_list;
    va_start(arg_list, format);
    [self _log:CrazyLog_Debug logTag:logTag selector:selector lineNumber:lineNumber format:format argumentList:arg_list];
    va_end(arg_list);
}

+ (void)verbose:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5)
{
    va_list arg_list;
    va_start(arg_list, format);
    [self _log:CrazyLog_Verbose logTag:logTag selector:selector lineNumber:lineNumber format:format argumentList:arg_list];
    va_end(arg_list);
}

+ (void)information:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5)
{
    va_list arg_list;
    va_start(arg_list, format);
    [self _log:CrazyLog_Information logTag:logTag selector:selector lineNumber:lineNumber format:format argumentList:arg_list];
    va_end(arg_list);
}

+ (void)warning:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5)
{
    va_list arg_list;
    va_start(arg_list, format);
    [self _log:CrazyLog_Warning logTag:logTag selector:selector lineNumber:lineNumber format:format argumentList:arg_list];
    va_end(arg_list);
}

+ (void)error:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5)
{
    va_list arg_list;
    va_start(arg_list, format);
    [self _log:CrazyLog_Error logTag:logTag selector:selector lineNumber:lineNumber format:format argumentList:arg_list];
    va_end(arg_list);
}

+ (void)_log:(CrazyLogLevel)level logTag:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format argumentList:(va_list)argumentList
{
    NSString * content = [[NSString alloc] initWithFormat:format arguments:argumentList];
    if (nil != [CrazyOptionMgr sharedInstance].crazyLogBlock) {
        CrazyLogContent * logContent = [[CrazyLogContent alloc] init];
        logContent.level       = level;
        logContent.logTag      = logTag;
        logContent.selector    = selector;
        logContent.lineNumber  = lineNumber;
        logContent.realContent = content;
        [CrazyOptionMgr sharedInstance].crazyLogBlock(logContent);
    }
    else {
        NSString * formatContent = [NSString stringWithFormat:@"%@ %@[%u:%llu][%@][%@:%@] %@ %@", [self logDateFormatString:[NSDate date]], [self currentProcessName], [self currentProcessID], [self currentThreadID], [self logLevelString:level], logTag, lineNumber, selector, content];
        printf("%s\n", formatContent.UTF8String);
    }
}


#pragma mark - private utils

+ (NSString *)logLevelString:(CrazyLogLevel)level
{
    switch (level) {
        case CrazyLog_Debug: return @"D";
        case CrazyLog_Verbose: return @"V";
        case CrazyLog_Information: return @"I";
        case CrazyLog_Warning: return @"W";
        case CrazyLog_Error: return @"E";
        default: return @"Unknown";
    }
}

+ (NSString *)logDateFormatString:(NSDate *)logDate
{
    static NSDateFormatter * dateFormatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS";
    });
    return [dateFormatter stringFromDate:logDate];
}

+ (uint32_t)currentProcessID
{
    return [NSProcessInfo processInfo].processIdentifier;
}

+ (uint64_t)currentThreadID
{
    uint64_t tid;
    pthread_threadid_np(NULL, &tid);
    return tid;
}

+ (NSString *)currentProcessName
{
    return [NSProcessInfo processInfo].processName;
}

@end
