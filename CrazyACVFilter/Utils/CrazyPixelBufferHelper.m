//
//  CrazyPixelBufferHelper.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyPixelBufferHelper.h"

#import "UIImage+Representation.h"

@implementation CrazyPixelBufferHelper

+ (CVPixelBufferRef)pixelBufferFromImage:(UIImage *)image
{
    NSData * rawImageData = [UIImage RawRepresentation:image pixelFormat:SVPixelFormat_BGRA];
    
    NSDictionary * attributes = @{
                                  (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{},
                                  (NSString *)kCVPixelBufferCGImageCompatibilityKey : @(YES),
                                  (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : @(YES),
                                  (NSString *)kCVPixelBufferCGBitmapContextCompatibilityKey : @(YES),
                                  };
    
    CVPixelBufferRef pixelBufferRef = NULL;
    CVReturn status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, image.size.width * image.scale, image.size.height * image.scale, kCVPixelFormatType_32BGRA, (void *)rawImageData.bytes, (NSUInteger)image.size.width * image.scale * 4, NULL, NULL, (__bridge CFDictionaryRef)(attributes), &pixelBufferRef);
    
    if (kCVReturnSuccess != status) {
        CrazyInnerLoge(@"create pixel buffer from UIImage failed!");
        return NULL;
    }
    
    return pixelBufferRef;
}

+ (CVPixelBufferRef)pixelBufferFromLayer:(CALayer *)layer
{
    return NULL;
}

+ (CVPixelBufferRef)openglEmptyPixelBuffer:(CGSize)size
                           pixelFormatType:(OSType)formatType
{
    CVPixelBufferRef pixelBuffer = NULL;
    
    NSDictionary * pbAttributes = @{
                                    (NSString *)kCVPixelBufferIOSurfacePropertiesKey : @{},
                                    (NSString *)kCVPixelBufferOpenGLESCompatibilityKey : @(YES),
                                    };
    
    CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, formatType, (__bridge CFDictionaryRef)(pbAttributes), &pixelBuffer);
    
    return pixelBuffer;
}

@end
