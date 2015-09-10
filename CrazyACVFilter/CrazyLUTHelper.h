//
//  CrazyLUTHelper.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CrazyACVFileHandle.h"

#import "CrazyShaderHelper.h"

@interface CrazyLUTHelper : NSObject

/**
 *  @brief 根据acv数据创建颜色查找表(acvTextureData)
 */
+ (void)generateACVLUT:(CrazyACVFileHandle *)acvFileHandler
        lutOutFilePath:(NSString *)lutOutFilePath
         dispatchQueue:(dispatch_queue_t)dispatchQueue
         finishedBlock:(void(^)(NSData */*acvTextureData*/))finishedBlock;


/**
 *  @brief 根据颜色查找表(acvTextureData), 生成对应的opengl texture
 */
+ (GLuint)generateACVFilterTexture:(NSData *)acvTextureData
                         glContext:(EAGLContext *)glContext;


/**
 *  @brief 根据acvIdentifier获取acv颜色查找表的本地存储路径
 */
+ (NSString *)acvLUTFilePath:(NSString *)acvIdentifier;

@end
