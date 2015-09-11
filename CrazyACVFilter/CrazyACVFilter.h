//
//  CrazyACVFilter.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CrazyACVRenderWrap.h"

/**
 *  @brief 通过解析photoshop acv 文件, 实现滤镜效果.
 *
 *  @attention
 *      采用Cubic Spline Interpolation实现颜色映射表的色值填充,
 *      使颜色查找表覆盖[0, 255]的范围.
 */
@interface CrazyACVFilter : NSObject

#pragma mark - filter

- (UIImage *)renderImage:(UIImage *)originalImage;

- (CVPixelBufferRef)renderPixelBuffer:(CVPixelBufferRef)oriPixelBuffer;


#pragma mark - is enabled

- (BOOL)isFilterEnabled;


#pragma mark - initialization

- (id)initWithACVFile:(NSString *)acvFilePath;

- (id)initWithACVFileURL:(NSURL *)acvFileURL;

- (id)initWithACVFile:(NSString *)acvFilePath exclusive:(BOOL)exclusive;

- (id)initWithACVFileURL:(NSURL *)acvFileURL exclusive:(BOOL)exclusive;

@end
