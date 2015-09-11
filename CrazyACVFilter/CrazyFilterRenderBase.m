//
//  CrazyFilterRenderBase.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyFilterRenderBase.h"

#import "CrazyFilterRenderMgr.h"

#import "CrazyShaderHelper.h"

NSString * const KSVACVFilterVertexShader = CrazyOPENGL_SHADER_NSSTRING(
    attribute vec4 position;
    attribute vec2 texCoord;
    
    varying vec2 texCoordVarying;
    
    void main()
    {
        gl_Position = position;
        
        texCoordVarying = texCoord;
    }
);


@implementation CrazyFilterRenderBase

#pragma mark - opengl render context

- (CVOpenGLESTextureCacheRef) filterTextureCache
{
    return [CrazyFilterRenderMgr sharedInstance].filterTextureCache;
}

- (EAGLContext *)currentContext
{
    return [CrazyFilterRenderMgr sharedInstance].currentContext;
}


#pragma mark - render pixel buffer

- (CVPixelBufferRef)renderPixelBuffer:(CVPixelBufferRef)oriPixelBuffer
                        acvIdentifier:(NSString *)acvIdentifier
                            glContext:(EAGLContext *)glContext
                 offscreenFrameBuffer:(GLuint)offscreenFrameBuffer
{
    return NULL;
}

#pragma mark - generate rgb texture

- (CVOpenGLESTextureRef)rgbTextureFromPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    return [[CrazyFilterRenderMgr sharedInstance] rgbTextureFromPixelBuffer:pixelBuffer];
}


#pragma mark - some opengl handle

- (NSString *)videoFilterFragmentShader
{
    return @"";
}

- (void)glProgramInitialization
{
    self.glACVFilterProgram = [CrazyShaderHelper glProgramWithVertexSource:KSVACVFilterVertexShader fragmentSource:self.videoFilterFragmentShader];
    
    if (0 != self.glACVFilterProgram) {
        self.positionAttrSlot = glGetAttribLocation(self.glACVFilterProgram, "position");
        
        self.texCoordAttrSlot = glGetAttribLocation(self.glACVFilterProgram, "texCoord");
    }
}

#pragma mark - singleton

- (id)init
{
    if (self = [super init]) {
        [EAGLContext setCurrentContext:self.currentContext];
        
        [self glProgramInitialization];
        
        [EAGLContext setCurrentContext:nil];
    }
    return self;
}

- (void)dealloc
{
    if (0 != self.glACVFilterProgram) {
        glDeleteProgram(self.glACVFilterProgram);
    }
}

@end
