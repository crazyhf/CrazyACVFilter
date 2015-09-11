//
//  CrazyPixelBufferHelper.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/11.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrazyPixelBufferHelper : NSObject

+ (CVPixelBufferRef)pixelBufferFromImage:(UIImage *)image;

+ (CVPixelBufferRef)pixelBufferFromLayer:(CALayer *)layer;

+ (CVPixelBufferRef)openglEmptyPixelBuffer:(CGSize)size
                           pixelFormatType:(OSType)formatType;

@end
