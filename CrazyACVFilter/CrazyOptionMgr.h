//
//  CrazyOptionMgr.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^crazy_log_block_t)(CrazyLogLevel level, NSString * tag, NSString * logContent);


@interface CrazyOptionMgr : NSObject

@property (nonatomic, strong) NSString * acvLUTFileDirectory;

@property (nonatomic, strong) crazy_log_block_t crazyLogBlock;


+ (instancetype)sharedInstance;

@end
