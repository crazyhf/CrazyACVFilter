//
//  CrazyOptionMgr.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyOptionMgr.h"

@implementation CrazyOptionMgr

#pragma mark - initialization

- (id)init
{
    if (self = [super init]) {
        [self crazyLogBlockInit];
        [self acvLUTFileDirectoryInit];
    }
    return self;
}

- (void)acvLUTFileDirectoryInit
{
    NSArray * directories = NSSearchPathForDirectoriesInDomains(
                                                                NSDocumentDirectory,
                                                                NSUserDomainMask, YES
                                                                );
    if (directories.count && (self.acvLUTFileDirectory = directories.firstObject).length) {
        if (NO == [self.acvLUTFileDirectory hasSuffix:@"/"]) {
            self.acvLUTFileDirectory = [self.acvLUTFileDirectory stringByAppendingString:@"/"];
        }
    } else {
        if (nil != self.crazyLogBlock) {
            CrazyLogw(@"get document directory failed");
        }
    }
}

- (void)crazyLogBlockInit
{
    ;
}


#pragma mark - singleton

+ (instancetype)sharedInstance
{
    static CrazyOptionMgr * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CrazyOptionMgr alloc] init];
    });
    return _instance;
}

@end
