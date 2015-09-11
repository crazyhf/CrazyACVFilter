//
//  CrazyACVRenderWrap.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const KCrazyACVFilterTextureChangedNotify;

@interface CrazyACVRenderWrap : NSObject

#pragma mark - register acv filter

- (void)registerACVData:(NSData *)acvFileData
          acvIdentifier:(NSString *)acvIdentifier;

- (void)clearACVTexture;


#pragma mark - is filter enabled

- (BOOL)isFilterEnabled:(NSString *)acvIdentifier;


#pragma mark - opengl context

- (EAGLContext *)currentContext;


#pragma mark - render pixel buffer

- (CVPixelBufferRef)renderPixelBuffer:(CVPixelBufferRef)oriPixelBuffer
                            glContext:(EAGLContext *)glContext
                 offscreenFrameBuffer:(GLuint)offscreenFrameBuffer;

#pragma mark - singleton

+ (instancetype)sharedInstance;

@end
