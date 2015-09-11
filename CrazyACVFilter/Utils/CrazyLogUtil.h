//
//  CrazyLogUtil.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

//===============================================================
#pragma mark - log macro

#if DEBUG
#define CrazyLogd(tag, ...) \
            [CrazyLogUtil debug:tag \
                       selector:[NSString stringWithUTF8String:__FUNCTION__] \
                     lineNumber:@(__LINE__) format:__VA_ARGS__]

#define CrazyLogv(tag, ...) \
            [CrazyLogUtil verbose:tag \
                         selector:[NSString stringWithUTF8String:__FUNCTION__] \
                       lineNumber:@(__LINE__) format:__VA_ARGS__]
#else
#define CrazyLogd(tag, ...)
#define CrazyLogv(tag, ...)
#endif

#define CrazyLogi(tag, ...) \
            [CrazyLogUtil information:tag \
                             selector:[NSString stringWithUTF8String:__FUNCTION__] \
                           lineNumber:@(__LINE__) format:__VA_ARGS__]

#define CrazyLogw(tag, ...) \
            [CrazyLogUtil warning:tag \
                         selector:[NSString stringWithUTF8String:__FUNCTION__] \
                       lineNumber:@(__LINE__) format:__VA_ARGS__]

#define CrazyLoge(tag, ...) \
            [CrazyLogUtil error:tag \
                       selector:[NSString stringWithUTF8String:__FUNCTION__] \
                     lineNumber:@(__LINE__) format:__VA_ARGS__]


#define CrazyACVFilterTag   @"CrazyACVFilter"


//===============================================================

typedef NS_ENUM(NSUInteger, CrazyLogLevel) {
    CrazyLog_Information,
    CrazyLog_Verbose,
    CrazyLog_Debug,
    CrazyLog_Warning,
    CrazyLog_Error,
};

@interface CrazyLogContent : NSObject

@property (nonatomic, strong) NSString * logTag;

@property (nonatomic, assign) CrazyLogLevel level;

@property (nonatomic, strong) NSString * selector;

@property (nonatomic, strong) NSNumber * lineNumber;

@property (nonatomic, strong) NSString * realContent;

@end


@interface CrazyLogUtil : NSObject

+ (void)debug:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

+ (void)verbose:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

+ (void)information:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

+ (void)warning:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

+ (void)error:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

@end
