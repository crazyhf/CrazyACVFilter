//
//  CrazyACVRender.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyACVRender.h"

#import "CrazyShaderHelper.h"

#import "CrazyPixelBufferHelper.h"


NSString * const KACVFilterFragmentShader = CrazyOPENGL_SHADER_NSSTRING(
    varying highp vec2  texCoordVarying;
    
    uniform sampler2D   filterTexture;
    
    uniform sampler2D   sourceTexture;
    
    void main()
    {
        highp vec4 resultColor = texture2D(sourceTexture, texCoordVarying);
        
        resultColor.r = texture2D(filterTexture, vec2(resultColor.r, 0)).r;
        resultColor.g = texture2D(filterTexture, vec2(resultColor.g, 0)).g;
        resultColor.b = texture2D(filterTexture, vec2(resultColor.b, 0)).b;
        
        gl_FragColor = resultColor;
    }
);

@interface CrazyACVRender()

#pragma mark - opengl shader

@property (nonatomic, assign) GLint  sourceTextureUniformSlot;

@property (nonatomic, assign) GLint  filterTextureUniformSlot;

@end

@implementation CrazyACVRender

#pragma mark - render pixel buffer

- (CVPixelBufferRef)renderPixelBuffer:(CVPixelBufferRef)oriPixelBuffer
                    acvTextureHandler:(GLuint)acvTextureHandler
                            glContext:(EAGLContext *)glContext
                 offscreenFrameBuffer:(GLuint)offscreenFrameBuffer
{
    if (0 == acvTextureHandler) return NULL;
    
    [EAGLContext setCurrentContext:glContext];
    
    GLsizei pbWidth  = (GLsizei)CVPixelBufferGetWidth(oriPixelBuffer);
    GLsizei pbHeight = (GLsizei)CVPixelBufferGetHeight(oriPixelBuffer);
    
    CVPixelBufferRef destPixelBuffer = [CrazyPixelBufferHelper openglEmptyPixelBuffer:CGSizeMake(pbWidth, pbHeight) pixelFormatType:CVPixelBufferGetPixelFormatType(oriPixelBuffer)];
    
    CVOpenGLESTextureRef destRGBTexture = [self rgbTextureFromPixelBuffer:destPixelBuffer];
    CVOpenGLESTextureRef oriRGBTexture  = [self rgbTextureFromPixelBuffer:oriPixelBuffer];
    
    do {
        if (NULL == destRGBTexture || NULL == oriRGBTexture) break;
        
        glBindFramebuffer(GL_FRAMEBUFFER, offscreenFrameBuffer);
        glFramebufferTexture2D(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, CVOpenGLESTextureGetTarget(destRGBTexture), CVOpenGLESTextureGetName(destRGBTexture), 0);
        
        { /// attach acv filter texture
            glActiveTexture(GL_TEXTURE0);
            glBindTexture(GL_TEXTURE_2D, acvTextureHandler);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
        
        { /// attach original texture
            glActiveTexture(GL_TEXTURE1);
            glBindTexture(CVOpenGLESTextureGetTarget(oriRGBTexture), CVOpenGLESTextureGetName(oriRGBTexture));
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
            glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
            glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
        }
        
        { /// opengl program initialization
            glUseProgram(self.glACVFilterProgram);
            { /// shader texture
                GLfloat quadVertexData[] = {
                    -1.0, 1.0, 1.0, 1.0, -1.0, -1.0, 1.0, -1.0,
                };
                
                // texture data varies from 0 -> 1, whereas vertex data varies from -1 -> 1
                GLfloat quadTextureData[] = {
                    0.0, 1.0, 1.0, 1.0, 0.0, 0.0, 1.0, 0.0,
                };
                
                glUniform1i(self.filterTextureUniformSlot, 0);
                glUniform1i(self.sourceTextureUniformSlot, 1);
                
                glVertexAttribPointer(self.positionAttrSlot, 2, GL_FLOAT, 0, 0, quadVertexData);
                glEnableVertexAttribArray(self.positionAttrSlot);
                
                glVertexAttribPointer(self.texCoordAttrSlot, 2, GL_FLOAT, 0, 0, quadTextureData);
                glEnableVertexAttribArray(self.texCoordAttrSlot);
            }
        }
        
        if (GL_FRAMEBUFFER_COMPLETE == glCheckFramebufferStatus(GL_FRAMEBUFFER)) {
            glViewport(0, 0, pbWidth, pbHeight);
            
            glClearColor(0.0f, 0.0f, 0.0f, 1.0f);
            glClear(GL_COLOR_BUFFER_BIT);
            
            // Blend function to draw the foreground frame
            glEnable(GL_BLEND);
            glBlendFunc(GL_ONE, GL_ZERO);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
            glFlush();
        }
        else {
            CrazyInnerLogd(@"failed to make complete framebuffer object %x", glCheckFramebufferStatus(GL_FRAMEBUFFER));
        }
    } while (false);
    
    CVOpenGLESTextureCacheFlush(self.filterTextureCache, 0);
    
    [EAGLContext setCurrentContext:nil];
    
    if (NULL != destPixelBuffer && NULL != destRGBTexture && NULL != oriRGBTexture) {
        CFRelease(destRGBTexture);
        CFRelease(oriRGBTexture);
        return destPixelBuffer;
    }
    
    if (NULL != destPixelBuffer) CFRelease(destPixelBuffer);
    if (NULL != destRGBTexture) CFRelease(destRGBTexture);
    if (NULL != oriRGBTexture) CFRelease(oriRGBTexture);
    
    return NULL;
}


#pragma mark - opengl fragment shader

- (NSString *)videoFilterFragmentShader
{
    return KACVFilterFragmentShader;
}


#pragma mark - singleton

- (id)init
{
    if (self = [super init]) {
        [EAGLContext setCurrentContext:self.currentContext];
        if (0 != self.glACVFilterProgram) {
            self.sourceTextureUniformSlot = glGetUniformLocation(self.glACVFilterProgram, "sourceTexture");
            
            self.filterTextureUniformSlot = glGetUniformLocation(self.glACVFilterProgram, "filterTexture");
        }
        [EAGLContext setCurrentContext:nil];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static CrazyACVRender * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CrazyACVRender alloc] init];
    });
    return _instance;
}

@end
