//
//  CrazyFilterRenderBase.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrazyFilterRenderBase : NSObject

#pragma mark - opengl shader

@property (nonatomic, assign) GLuint glACVFilterProgram;

@property (nonatomic, assign) GLint  positionAttrSlot;

@property (nonatomic, assign) GLint  texCoordAttrSlot;


#pragma mark - opengl render context

- (CVOpenGLESTextureCacheRef) filterTextureCache;

- (EAGLContext *)currentContext;


#pragma mark - render pixel buffer

- (CVPixelBufferRef)renderPixelBuffer:(CVPixelBufferRef)oriPixelBuffer
                        acvIdentifier:(NSString *)acvIdentifier
                            glContext:(EAGLContext *)glContext
                 offscreenFrameBuffer:(GLuint)offscreenFrameBuffer;

#pragma mark - generate rgb texture

- (CVOpenGLESTextureRef)rgbTextureFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;

#pragma mark - opengl fragment shader

- (NSString *)videoFilterFragmentShader;

@end
