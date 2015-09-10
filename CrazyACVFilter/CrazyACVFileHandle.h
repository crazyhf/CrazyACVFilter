//
//  CrazyACVFileHandle.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief
 *      photoshop acv 文件解析, acv文件是photoshop导出的滤镜曲线描述文件.
 *
 *  @attention
 *      解析得到的rgbSplinePoints、greenSplinePoints、
 *      blueSplinePoints、redSplinePoints, 保存着一系列的(x, y)值.
 *
 *      一组(x, y)值代表一个色值映射关系, 即色值x应该映射为色值y.
 *
 *      此外, rgbSplinePoints、greenSplinePoints、blueSplinePoints、
 *      redSplinePoints 是经过cubic spline插值的, 覆盖[0, 255]的完整色值映射表
 *
 *      从acv文件解析得到的, 每个通道包含的(x, y)值有限, 所以如果x的范围没有
 *      覆盖到[0, 255], 则应该采用插值算法, 填充得到完整的色值映射表.
 */
@interface CrazyACVFileHandle : NSObject

@property (nonatomic, strong, readonly) NSArray * greenSplinePoints;

@property (nonatomic, strong, readonly) NSArray * blueSplinePoints;

@property (nonatomic, strong, readonly) NSArray * redSplinePoints;

@property (nonatomic, strong, readonly) NSArray * rgbSplinePoints;


- (id)initWithACVFile:(NSString *)acvFilePath;

- (id)initWithACVFileURL:(NSURL *)acvFileURL;

- (id)initWithACVData:(NSData *)acvFileData;

@end

