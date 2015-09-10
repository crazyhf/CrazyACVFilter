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
#define CrazyLogd(...) \
            [CrazyLogUtil debug:CrazyACVFilterTag \
                       selector:[NSString stringWithUTF8String:__FUNCTION__] \
                     lineNumber:@(__LINE__) format:__VA_ARGS__]

#define CrazyLogv(...) \
            [CrazyLogUtil verbose:CrazyACVFilterTag \
                         selector:[NSString stringWithUTF8String:__FUNCTION__] \
                       lineNumber:@(__LINE__) format:__VA_ARGS__]
#else
#define CrazyLogd(...)
#define CrazyLogv(...)
#endif

#define CrazyLogi(...) \
            [CrazyLogUtil information:CrazyACVFilterTag \
                             selector:[NSString stringWithUTF8String:__FUNCTION__] \
                           lineNumber:@(__LINE__) format:__VA_ARGS__]

#define CrazyLogw(...) \
            [CrazyLogUtil warning:CrazyACVFilterTag \
                         selector:[NSString stringWithUTF8String:__FUNCTION__] \
                       lineNumber:@(__LINE__) format:__VA_ARGS__]

#define CrazyLoge(...) \
            [CrazyLogUtil error:CrazyACVFilterTag \
                       selector:[NSString stringWithUTF8String:__FUNCTION__] \
                     lineNumber:@(__LINE__) format:__VA_ARGS__]


//===============================================================

#define CrazyACVFilterTag   @"CrazyACVFilter"


typedef NS_ENUM(NSUInteger, CrazyLogLevel) {
    CrazyLog_Information,
    CrazyLog_Verbose,
    CrazyLog_Debug,
    CrazyLog_Warning,
    CrazyLog_Error,
};


@interface CrazyLogUtil : NSObject

+ (void)debug:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

+ (void)verbose:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

+ (void)information:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

+ (void)warning:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

+ (void)error:(NSString *)logTag selector:(NSString *)selector lineNumber:(NSNumber *)lineNumber format:(NSString *)format , ... NS_FORMAT_FUNCTION(4, 5);

@end
