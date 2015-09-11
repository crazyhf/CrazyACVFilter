//
//  CrazyACVRenderWrap.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyACVRenderWrap.h"

#import "CrazyACVRender.h"

#import "CrazyLUTHelper.h"

#import "CrazyFileUtil.h"

#define KCrazyACVPreProcessQueueLable   "com.crazy.enterprise.crazyacvfilter.acvpreprocess_queue_serial"

NSString * const KCrazyACVFilterTextureChangedNotify = @"CrazyACVFilterTextureChangedNotify";


@interface CrazyACVRenderWrap()

@property (nonatomic, strong) NSString * curACVIdentifier;

@property (nonatomic, assign) GLuint curACVTextureHandler;


#pragma mark - acv pre process queue

@property (nonatomic, strong) dispatch_queue_t acvPreProcessQueue;

@end

@implementation CrazyACVRenderWrap

#pragma mark - register acv filter

- (void)registerACVData:(NSData *)acvFileData acvIdentifier:(NSString *)acvIdentifier
{
    if (0 == acvIdentifier.length
        || YES == [self.curACVIdentifier isEqualToString:acvIdentifier]) {
        return;
    }
    
    [self clearACVTexture];
    
    self.curACVIdentifier = acvIdentifier;
    
    NSString * acvLUTFilePath = [CrazyLUTHelper acvLUTFilePath:acvIdentifier];
    
    if (YES == [CrazyFileUtil isFileExisted:acvLUTFilePath]) {
        NSData * acvLUTData = [NSData dataWithContentsOfFile:acvLUTFilePath];
        self.curACVTextureHandler = [CrazyLUTHelper generateACVFilterTexture:acvLUTData glContext:[CrazyACVRender sharedInstance].currentContext];
    } else {
        CrazyACVFileHandle * anACVFileHandler = [[CrazyACVFileHandle alloc] initWithACVData:acvFileData];
        
        __weak CrazyACVRenderWrap * weakSelf = self;
        [CrazyLUTHelper generateACVLUT:anACVFileHandler lutOutFilePath:acvLUTFilePath dispatchQueue:self.acvPreProcessQueue finishedBlock:^(NSData * acvTextureData) {
            weakSelf.curACVTextureHandler = [CrazyLUTHelper generateACVFilterTexture:acvTextureData glContext:[CrazyACVRender sharedInstance].currentContext];
        }];
    }
}

- (BOOL)isFilterEnabled:(NSString *)acvIdentifier
{
    if (0 != acvIdentifier.length
        && YES == [self.curACVIdentifier isEqualToString:acvIdentifier]) {
        return (0 != self.curACVTextureHandler);
    }
    return NO;
}

- (void)setCurACVTextureHandler:(GLuint)curACVTextureHandler
{
    _curACVTextureHandler = curACVTextureHandler;
    
    if (0 != _curACVTextureHandler) {
        [[NSNotificationCenter defaultCenter] postNotificationName:KCrazyACVFilterTextureChangedNotify object:self];
    }
}


#pragma mark - opengl context

- (EAGLContext *)currentContext
{
    return [CrazyACVRender sharedInstance].currentContext;
}


#pragma mark - render pixel buffer

- (CVPixelBufferRef)renderPixelBuffer:(CVPixelBufferRef)oriPixelBuffer
                            glContext:(EAGLContext *)glContext
                 offscreenFrameBuffer:(GLuint)offscreenFrameBuffer
{
    return [[CrazyACVRender sharedInstance] renderPixelBuffer:oriPixelBuffer acvTextureHandler:self.curACVTextureHandler glContext:glContext offscreenFrameBuffer:offscreenFrameBuffer];
}


#pragma mark - acv filter texture handle

- (void)clearACVTexture
{
    if (0 != self.curACVTextureHandler) {
        glDeleteTextures(1, &_curACVTextureHandler);
        self.curACVTextureHandler = 0;
    }
}


#pragma mark - singleton

- (id)init
{
    if (self = [super init]) {
        self.acvPreProcessQueue = dispatch_queue_create(KCrazyACVPreProcessQueueLable, DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)dealloc
{
    [self clearACVTexture];
}

+ (instancetype)sharedInstance
{
    static CrazyACVRenderWrap * _instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[CrazyACVRenderWrap alloc] init];
    });
    return _instance;
}

@end
