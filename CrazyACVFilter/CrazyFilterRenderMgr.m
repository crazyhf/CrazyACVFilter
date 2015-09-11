//
//  CrazyFilterRenderMgr.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyFilterRenderMgr.h"

#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/EAGL.h>

@implementation CrazyFilterRenderMgr

#pragma mark - generate rgb texture

- (CVOpenGLESTextureRef)rgbTextureFromPixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (NULL == self.filterTextureCache) {
        CrazyInnerLogw(@"the filter texture cache is NULL");
        return NULL;
    }
    
    CVOpenGLESTextureCacheFlush(self.filterTextureCache, 0);
    
    GLsizei pbWidth  = (GLsizei)CVPixelBufferGetWidth(pixelBuffer);
    GLsizei pbHeight = (GLsizei)CVPixelBufferGetHeight(pixelBuffer);
    
    CVOpenGLESTextureRef rgbTexture = NULL;
    
    CVReturn result = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.filterTextureCache, pixelBuffer, NULL, GL_TEXTURE_2D, GL_RGBA, pbWidth, pbHeight, GL_BGRA, GL_UNSIGNED_BYTE, 0, &rgbTexture);
    
    if (NULL == rgbTexture || kCVReturnSuccess != result) {
        CrazyInnerLogd(@"CVOpenGLESTextureCacheCreateTextureFromImage failed, error : %d", result);
    }
    
    return rgbTexture;
}


#pragma mark - some opengl handle

- (void)renderInitialization
{
    [self clearRenderContext];
    
    CVReturn result = CVOpenGLESTextureCacheCreate(
                                                   kCFAllocatorDefault,
                                                   NULL, self.currentContext,
                                                   NULL, &_filterTextureCache
                                                   );
    if (kCVReturnSuccess != result) {
        CrazyInnerLoge(@"CVOpenGLESTextureCacheCreate failed, error : %d", result);
    }
}

- (void)clearRenderContext
{
    if (NULL != self.filterTextureCache) {
        CFRelease(self.filterTextureCache);
        self.filterTextureCache = NULL;
    }
}


#pragma mark - singleton

- (id)init
{
    if (self = [super init]) {
        self.currentContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
        
        [EAGLContext setCurrentContext:self.currentContext];
        
        [self renderInitialization];
        
        [EAGLContext setCurrentContext:nil];
    }
    return self;
}

- (void)dealloc
{
    [self clearRenderContext];
}

+ (instancetype)sharedInstance
{
    static CrazyFilterRenderMgr * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CrazyFilterRenderMgr alloc] init];
    });
    return _instance;
}

@end
