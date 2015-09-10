//
//  CrazyACVFileHandle.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyACVFileHandle.h"

#import "CrazyCubicSpline.h"

#import "CrazyFileUtil.h"

/**
 *  @brief acv file format
 *      字节数             值描述
 *      2                 Version ( = 1 or = 4)
 *
 *      2                 Version 1 = bit map of curves in file
 *                        Version 4 = count of curves in the file
 *
 *      The following is the data for each curve specified by count above
 *
 *      2                 Count of points in the curve (short integer from 2...19)
 *
 *      point count * 4   Curve points. Each curve point is a pair of short integers
 *                        where the first number is the output value (vertical coordinate
 *                        on the Curves dialog graph) and the second is the input value.
 *                        All coordinates have range 0 to 255. See also See Null curves below.
 */
@interface CrazyACVFileHandle()

@property (nonatomic, assign) uint16_t acvVersion;

@property (nonatomic, assign) uint16_t totalACVCurves;

@end


@implementation CrazyACVFileHandle

- (void)generateWithACVData:(NSData *)acvData
{
    Byte * aRawBytes = (Byte *)acvData.bytes;
    
    self.acvVersion     = [CrazyACVFileHandle popInt16FromBytes:&aRawBytes];
    self.totalACVCurves = [CrazyACVFileHandle popInt16FromBytes:&aRawBytes];
    
    NSMutableArray * allCurves = [NSMutableArray arrayWithCapacity:self.totalACVCurves];
    
    for (NSInteger index = 0; index < self.totalACVCurves; index++)
    {
        uint16_t aPointCount = [CrazyACVFileHandle popInt16FromBytes:&aRawBytes];
        
        NSMutableArray * aXValArray   = [NSMutableArray arrayWithCapacity:aPointCount];
        NSMutableArray * aCurvePoints = [NSMutableArray arrayWithCapacity:aPointCount];
        for (NSInteger iPoint = 0; iPoint < aPointCount; iPoint++)
        {
            uint16_t yVal = [CrazyACVFileHandle popInt16FromBytes:&aRawBytes];
            uint16_t xVal = [CrazyACVFileHandle popInt16FromBytes:&aRawBytes];
            
            if (NO == [aXValArray containsObject:@(xVal)]) {
                [aXValArray addObject:@(xVal)];
                [aCurvePoints addObject:[NSValue valueWithCGPoint:CGPointMake(xVal, yVal)]];
            }
        }
        [allCurves addObject:aCurvePoints];
    }
    
    _redSplinePoints = [allCurves[1] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 CGPointValue].x > [obj2 CGPointValue].x ? NSOrderedDescending : NSOrderedAscending;
    }];
    _blueSplinePoints = [allCurves[3] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 CGPointValue].x > [obj2 CGPointValue].x ? NSOrderedDescending : NSOrderedAscending;
    }];
    _greenSplinePoints = [allCurves[2] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 CGPointValue].x > [obj2 CGPointValue].x ? NSOrderedDescending : NSOrderedAscending;
    }];
    _rgbSplinePoints = [allCurves[0] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 CGPointValue].x > [obj2 CGPointValue].x ? NSOrderedDescending : NSOrderedAscending;
    }];
    
    [self cubicSplineInterpolation];
}


#pragma mark - Cubic Spline Interpolation

/**
 *  @brief 采用Cubic Spline Interpolation(三次样条插值)
 */
- (void)cubicSplineInterpolation
{
    _greenSplinePoints = [CrazyCubicSpline cubicSpline:self.greenSplinePoints upperBound:255 lowerBound:0];
    _blueSplinePoints  = [CrazyCubicSpline cubicSpline:self.blueSplinePoints upperBound:255 lowerBound:0];
    _redSplinePoints = [CrazyCubicSpline cubicSpline:self.redSplinePoints upperBound:255 lowerBound:0];
    _rgbSplinePoints = [CrazyCubicSpline cubicSpline:self.rgbSplinePoints upperBound:255 lowerBound:0];
    
    //CrazyLogd(@"cubic spline interpolation success, redSplinePoints : %@ \ngreenSplinePoints : %@ \nblueSplinePoints : %@ \nrgbSplinePoints : %@", self.redSplinePoints, self.greenSplinePoints, self.blueSplinePoints, self.rgbSplinePoints);
}



#pragma mark - private utils

+ (uint16_t)int16FromBytes:(Byte * const *)constBytesRef
{
    uint16_t result;
    memcpy(&result, *constBytesRef, sizeof(result));
    return CFSwapInt16BigToHost(result);
}

+ (uint16_t)popInt16FromBytes:(Byte **)bytesRef
{
    uint16_t result = [self int16FromBytes:bytesRef];
    return (*bytesRef = *bytesRef + sizeof(result), result);
}


#pragma mark - initialization

- (id)initWithACVFile:(NSString *)acvFilePath
{
    if (YES == [CrazyFileUtil isFileExisted:acvFilePath]) {
        NSData * anACVData = [NSData dataWithContentsOfFile:acvFilePath];
        return [self initWithACVData:anACVData];
    }
    
    CrazyLoge(@"the acv file[%@] is not existed", acvFilePath);
    return nil;
}

- (id)initWithACVFileURL:(NSURL *)acvFileURL
{
    NSData * anACVData = [NSData dataWithContentsOfURL:acvFileURL];
    return [self initWithACVData:anACVData];
}

- (id)initWithACVData:(NSData *)acvFileData
{
    if (0 != acvFileData.length) {
        if (self = [super init]) {
            [self generateWithACVData:acvFileData];
        }
        return self;
    }
    
    CrazyLoge(@"the acv data length is 0, acv data : %@", acvFileData);
    return nil;
}

- (id)init
{
    if (self = [super init]) {
        SVGLAssertW(NO, @"SVACVFileHandle init is not support");
    }
    return self;
}


@end
