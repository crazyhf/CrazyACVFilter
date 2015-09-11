//
//  CrazyACVFilter.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyACVFilter.h"

#import "CrazyFileUtil.h"

#import "CrazyShaderHelper.h"

#import "CrazyPixelBufferHelper.h"

@interface CrazyACVFilter()

@property (nonatomic, assign) BOOL exclusive;

@property (nonatomic, strong) CrazyACVRenderWrap * exclusiveRender;

#pragma mark -

@property (nonatomic, assign) GLuint offscreenFrameBuffer;


#pragma mark - opengl context

@property (nonatomic, strong) EAGLContext * currentContext;


#pragma mark - filter texture

@property (nonatomic, strong) NSString * filterIdentifier;

@end

@implementation CrazyACVFilter

- (UIImage *)renderImage:(UIImage *)originalImage
{
    if (nil != originalImage) {
        CVPixelBufferRef oriPixelBuffer  = [CrazyPixelBufferHelper pixelBufferFromImage:originalImage];
        CVPixelBufferRef destPixelBuffer = [self renderPixelBuffer:oriPixelBuffer];
        
        if (NULL != destPixelBuffer) {
            CIImage * aCIImage   = [CIImage imageWithCVPixelBuffer:destPixelBuffer];
            CGImageRef aImageRef = [[CIContext contextWithOptions:nil] createCGImage:aCIImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(destPixelBuffer), CVPixelBufferGetHeight(destPixelBuffer))];
            
            originalImage = [UIImage imageWithCGImage:aImageRef];
            
            CGImageRelease(aImageRef);
            CFRelease(destPixelBuffer);
        }
        
        if (NULL != oriPixelBuffer) {
            CFRelease(oriPixelBuffer);
        }
    }
    return originalImage;
}

- (CVPixelBufferRef)renderPixelBuffer:(CVPixelBufferRef)oriPixelBuffer
{
    return [self.renderInstance renderPixelBuffer:oriPixelBuffer
                                        glContext:self.currentContext
                             offscreenFrameBuffer:self.offscreenFrameBuffer];
}


#pragma mark - is enabled

- (BOOL)isFilterEnabled
{
    return [self.renderInstance isFilterEnabled:self.filterIdentifier];
}


#pragma mark - SVACVRender instance

- (CrazyACVRenderWrap *)renderInstance
{
    if (YES == self.exclusive) {
        if (nil == self.exclusiveRender) {
            self.exclusiveRender = [[CrazyACVRenderWrap alloc] init];
        }
        return self.exclusiveRender;
    } else {
        return [CrazyACVRenderWrap sharedInstance];
    }
}


#pragma mark - initialization

- (id)initWithACVFile:(NSString *)acvFilePath
{
    return [self initWithACVFile:acvFilePath exclusive:NO];
}

- (id)initWithACVFileURL:(NSURL *)acvFileURL
{
    return [self initWithACVFileURL:acvFileURL exclusive:NO];
}

- (id)initWithACVFile:(NSString *)acvFilePath exclusive:(BOOL)exclusive
{
    if (YES == [CrazyFileUtil isFileExisted:acvFilePath]) {
        NSData * acvData = [NSData dataWithContentsOfFile:acvFilePath];
        return [self initWithACVData:acvData acvIdentifier:acvFilePath.lastPathComponent exclusive:exclusive];
    }
    
    CrazyInnerLoge(@"the acv file[%@] is not existed", acvFilePath);
    return nil;
}

- (id)initWithACVFileURL:(NSURL *)acvFileURL exclusive:(BOOL)exclusive
{
    NSData * acvData = [NSData dataWithContentsOfURL:acvFileURL];
    if (0 != acvData.length) {
        return [self initWithACVData:acvData acvIdentifier:acvFileURL.path.lastPathComponent exclusive:exclusive];
    }
    return nil;
}

- (id)initWithACVData:(NSData *)acvFileData
        acvIdentifier:(NSString *)acvIdentifier exclusive:(BOOL)exclusive
{
    if (self = [super init]) {
        self.exclusive = exclusive;
        self.filterIdentifier = acvIdentifier;
        
        CrazyACVRenderWrap * anACVRender = self.renderInstance;
        
        self.currentContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2
                                                    sharegroup:anACVRender.currentContext.sharegroup];
        
        [anACVRender registerACVData:acvFileData acvIdentifier:self.filterIdentifier];
        
        [EAGLContext setCurrentContext:self.currentContext];
        
        glDisable(GL_DEPTH_TEST);
        glGenFramebuffers(1, &_offscreenFrameBuffer);
        glBindFramebuffer(GL_FRAMEBUFFER, self.offscreenFrameBuffer);
        
        [EAGLContext setCurrentContext:nil];
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        CrazyAssertW(NO, @"SVACVFileHandle init is not support");
    }
    return self;
}

- (void)dealloc
{
    if (0 != self.offscreenFrameBuffer) {
        glDeleteFramebuffers(1, &_offscreenFrameBuffer);
        self.offscreenFrameBuffer = 0;
    }
}

@end
