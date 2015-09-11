//
//  UIImage+Representation.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, SVPixelFormat) {
    SVPixelFormat_RGBA, // kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast
    SVPixelFormat_ABGR, // kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast
    SVPixelFormat_ARGB, // kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedFirst
    SVPixelFormat_BGRA, // kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
};

@interface UIImage (Representation)

/**
 *  @brief 获取UIImage的原生data
 */
+ (NSData *)RawRepresentation:(UIImage *)image
                  pixelFormat:(SVPixelFormat)pixelFormat;

/**
 *  @brief 将image转换成png data, 不进行压缩
 */
+ (NSData *)PNGRepresentation:(UIImage *)image;

/**
 *  @brief 将image转换成png data
 *  @param quality 压缩值(0.0 ~ 1.0) 值为1.0时, 只有目标格式支持压缩, 才会进行压缩
 */
+ (NSData *)PNGRepresentation:(UIImage *)image compressionQuality:(CGFloat)quality;

/**
 *  @brief 将image转换成jpeg data
 *  @param quality 压缩值(0.0 ~ 1.0) 值为1.0时, 只有目标格式支持压缩, 才会进行压缩
 */
+ (NSData *)JPEGRepresentation:(UIImage *)image compressionQuality:(CGFloat)quality;

/**
 *  @brief 将一组images @[UIImage] 转换成gif data
 *  @param quality 压缩值(0.0 ~ 1.0) 值为1.0时, 只有目标格式支持压缩, 才会进行压缩
 *  @param frameRate 与images图片序列的帧率
 */
+ (NSData *)GIFRepresentation:(NSArray *)images
                    frameRate:(unsigned)frameRate compressionQuality:(CGFloat)quality;

/**
 *  @brief 将image转换成其他像素格式的UIImage
 */
+ (UIImage *)convertImage:(UIImage *)image pixelFormat:(SVPixelFormat)pixelFormat;

@end
