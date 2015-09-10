//
//  CrazyLUTHelper.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyLUTHelper.h"

@implementation CrazyLUTHelper

#pragma mark - generate acv filter LUT

+ (void)generateACVLUT:(CrazyACVFileHandle *)acvFileHandler
        lutOutFilePath:(NSString *)lutOutFilePath
         dispatchQueue:(dispatch_queue_t)dispatchQueue
         finishedBlock:(void(^)(NSData */*acvTextureData*/))finishedBlock
{
    dispatch_async(dispatchQueue, ^{
        if ((acvFileHandler.redSplinePoints.count >= 256)
            && (acvFileHandler.rgbSplinePoints.count >= 256)
            && (acvFileHandler.blueSplinePoints.count >= 256)
            && (acvFileHandler.greenSplinePoints.count >= 256))
        {
            GLubyte acvTextureByte[256 * 4];
            for (NSUInteger index = 0; index < 256; index++)
            {
                GLubyte blue = fmin(fmax([acvFileHandler.blueSplinePoints[index] CGPointValue].y, 0), 255);
                acvTextureByte[index * 4] = fmin(fmax([acvFileHandler.rgbSplinePoints[blue] CGPointValue].y, 0), 255);
                
                GLubyte green = fmin(fmax([acvFileHandler.greenSplinePoints[index] CGPointValue].y, 0), 255);
                acvTextureByte[index * 4 + 1] = fmin(fmax([acvFileHandler.rgbSplinePoints[green] CGPointValue].y, 0), 255);
                
                GLubyte red = fmin(fmax([acvFileHandler.redSplinePoints[index] CGPointValue].y, 0), 255);
                acvTextureByte[index * 4 + 2] = fmin(fmax([acvFileHandler.rgbSplinePoints[red] CGPointValue].y, 0), 255);
                
                acvTextureByte[index * 4 + 3] = 255;
            }
            
            NSData * acvTextureData = [NSData dataWithBytes:acvTextureByte length:256 * 4];
            [acvTextureData writeToFile:lutOutFilePath atomically:YES];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (nil != finishedBlock) {
                    finishedBlock(acvTextureData);
                }
            });
        }
        else {
            CrazyLogw(@"generateACVLUT failed, spline points count[red:%@, green:%@, blue:%@, rgb:%@]", @(acvFileHandler.redSplinePoints.count), @(acvFileHandler.greenSplinePoints.count), @(acvFileHandler.blueSplinePoints.count), @(acvFileHandler.rgbSplinePoints.count));
        }
    });
}


#pragma mark - acv filter texture handle

+ (GLuint)generateACVFilterTexture:(NSData *)acvTextureData glContext:(EAGLContext *)glContext
{
    GLuint aGLTextureHandler = 0;
    
    EAGLContext * aGLContext = [EAGLContext currentContext];
    if (glContext != aGLContext) {
        if (NO == [EAGLContext setCurrentContext:glContext]) {
            CrazyLoge(@"setCurrentContext failed!");
            return aGLTextureHandler;
        }
    }
    
    glActiveTexture(GL_TEXTURE0);
    glGenTextures(1, &aGLTextureHandler);
    glBindTexture(GL_TEXTURE_2D, aGLTextureHandler);
    
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    
    if (0 != acvTextureData.length)
    {
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, (GLsizei)acvTextureData.length / 4, 1, 0, GL_BGRA, GL_UNSIGNED_BYTE, acvTextureData.bytes);
    }
    else {
        if (0 != aGLTextureHandler) {
            glDeleteTextures(1, &aGLTextureHandler);
            aGLTextureHandler = 0;
        }
    }
    
    if (aGLContext != glContext) {
        [EAGLContext setCurrentContext:aGLContext];
    }
    
    return aGLTextureHandler;
}


#pragma mark - acv lut file path

+ (NSString *)acvLUTFilePath:(NSString *)acvIdentifier
{
    NSString * aDirectory = [CrazyOptionMgr sharedInstance].acvLUTFileDirectory;
    if (0 != aDirectory.length) {
        NSString * acvLUTName = [NSString stringWithFormat:@"%@.acv", acvIdentifier];
        return [aDirectory stringByAppendingPathComponent:acvLUTName];
    }
    return @"";
}

@end
