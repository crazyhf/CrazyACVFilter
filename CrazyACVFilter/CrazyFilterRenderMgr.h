//
//  CrazyFilterRenderMgr.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrazyFilterRenderMgr : NSObject

@property (nonatomic, assign) CVOpenGLESTextureCacheRef filterTextureCache;

#pragma mark - opengl context

@property (nonatomic, strong) EAGLContext * currentContext;


#pragma mark - generate rgb texture

- (CVOpenGLESTextureRef)rgbTextureFromPixelBuffer:(CVPixelBufferRef)pixelBuffer;


+ (instancetype)sharedInstance;

@end
