//
//  CrazyACVRender.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyFilterRenderBase.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface CrazyACVRender : CrazyFilterRenderBase

#pragma mark - render pixel buffer

- (CVPixelBufferRef)renderPixelBuffer:(CVPixelBufferRef)oriPixelBuffer
                    acvTextureHandler:(GLuint)acvTextureHandler
                            glContext:(EAGLContext *)glContext
                 offscreenFrameBuffer:(GLuint)offscreenFrameBuffer;

#pragma mark - singleton

+ (instancetype)sharedInstance;

@end
