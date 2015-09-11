//
//  UIImage+Representation.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>
#import <ImageIO/ImageIO.h>

#import "UIImage+Representation.h"

@implementation UIImage (Representation)

+ (NSData *)RawRepresentation:(UIImage *)image
                  pixelFormat:(SVPixelFormat)pixelFormat
{
    NSUInteger imgWidth  = image.size.width * image.scale;
    NSUInteger imgHeight = image.size.height * image.scale;
    
    void * pRawData = malloc(imgWidth * imgHeight * 4);
    
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    
    CGBitmapInfo aBitmapInfo = [self cgbitmapinfoFromPixelFormat:pixelFormat];
    
    CGContextRef context = CGBitmapContextCreate(pRawData, imgWidth, imgHeight, 8, 4 * imgWidth, colorSpaceRef, aBitmapInfo);
    
    CGContextConcatCTM(context, CGAffineTransformMakeRotation(0));
    CGContextDrawImage(context, CGRectMake(0, 0, imgWidth, imgHeight), image.CGImage);
    
    CGColorSpaceRelease(colorSpaceRef);
    CGContextRelease(context);
    
    NSData * rawNSData = [NSData dataWithBytes:pRawData length:imgWidth * imgHeight * 4];
    
    free(pRawData);
    
    return rawNSData;
}

+ (NSData *)PNGRepresentation:(UIImage *)image
{
    return UIImagePNGRepresentation(image);
}

+ (NSData *)PNGRepresentation:(UIImage *)image compressionQuality:(CGFloat)quality
{
    CFMutableDataRef mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0);
    
    CGImageDestinationRef pngDest = CGImageDestinationCreateWithData(mutableData, kUTTypePNG, 1, NULL);
    
    NSDictionary * properties = @{
                                  (NSString *)kCGImageDestinationLossyCompressionQuality : @(quality)
                                  };
    CGImageDestinationAddImage(pngDest, image.CGImage, (CFDictionaryRef)properties);
    
    CGImageDestinationFinalize(pngDest);
    
    CFRelease(pngDest);
    
    return CFBridgingRelease(mutableData);
}

+ (NSData *)JPEGRepresentation:(UIImage *)image compressionQuality:(CGFloat)quality
{
    return UIImageJPEGRepresentation(image, quality);
}

+ (NSData *)GIFRepresentation:(NSArray *)images frameRate:(unsigned)frameRate compressionQuality:(CGFloat)quality
{
    CGFloat frameDelayTime = 0.5;
    
    if (0 != frameRate) frameDelayTime = 1.0 / frameRate;
    
    CFMutableDataRef mutableData = CFDataCreateMutable(kCFAllocatorDefault, 0);
    
    CGImageDestinationRef gifDest = CGImageDestinationCreateWithData(mutableData, kUTTypeGIF, images.count, NULL);
    
    for (NSUInteger index = 0; index < images.count; index++)
    {
        UIImage * anImage  = images[index];
        
        NSDictionary * frameProperties = @{
                                           (NSString *)kCGImagePropertyGIFDictionary : @{
                                                   (NSString *)kCGImagePropertyGIFDelayTime : @(frameDelayTime)
                                                   },
                                           (NSString *)kCGImageDestinationLossyCompressionQuality : @(quality)
                                           };
        CGImageDestinationAddImage(gifDest, anImage.CGImage, (CFDictionaryRef)frameProperties);
    }
    
    NSDictionary * gifProperties = @{
                                     (NSString *)kCGImagePropertyGIFDictionary : @{
                                             (NSString *)kCGImagePropertyGIFLoopCount : @(0)
                                             }
                                     };
    CGImageDestinationSetProperties(gifDest, (CFDictionaryRef)gifProperties);
    
    CGImageDestinationFinalize(gifDest);
    
    CFRelease(gifDest);
    
    return CFBridgingRelease(mutableData);
}


+ (UIImage *)convertImage:(UIImage *)image pixelFormat:(SVPixelFormat)pixelFormat
{
    NSData * anImageData = [UIImage RawRepresentation:image pixelFormat:pixelFormat];
    
    if (0 != anImageData.length) {
        CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
        UIImage * resultImage = nil;
        
        CGDataProviderRef provider = CGDataProviderCreateWithData(
                                                                  NULL, anImageData.bytes,
                                                                  image.scale * image.size.width * image.scale * image.size.height * 4,
                                                                  NULL
                                                                  );
        CGImageRef imageRef = CGImageCreate(
                                            image.scale * image.size.width, image.scale * image.size.height, 8, 32, 4 * image.scale * image.size.width, colorSpaceRef,
                                            [self cgbitmapinfoFromPixelFormat:pixelFormat], provider,
                                            NULL, YES, kCGRenderingIntentDefault
                                            );
        
        resultImage = [UIImage imageWithCGImage:imageRef];
        
        CGImageRelease(imageRef);
        CGDataProviderRelease(provider);
        CGColorSpaceRelease(colorSpaceRef);
        
        return resultImage;
    }
    return nil;
}


#pragma mark - SVPixelFormat util

+ (CGBitmapInfo)cgbitmapinfoFromPixelFormat:(SVPixelFormat)pixelFormat
{
    CGBitmapInfo aBitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast;
    if (SVPixelFormat_ABGR == pixelFormat) {
        aBitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast;
    } else if (SVPixelFormat_ARGB == pixelFormat) {
        aBitmapInfo = kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst;
    } else if (SVPixelFormat_BGRA == pixelFormat) {
        aBitmapInfo = kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst;
    }
    return aBitmapInfo;
}


@end
