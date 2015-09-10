//
//  CrazyCubicSpline.m
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import "CrazyCubicSpline.h"

@implementation CrazyCubicSpline

/**
 *  @attention
 *      i ∊ (0, 1, 2, ... , n-2), j = i + 1, C0 = 0, Cn-1 = 0
 *      Hi = Xj - Xi, Gradient_i = (Yj - Yi) / Hi
 *
 *      Bi = Gradient_i - 1/6 * Hi * (4 * Ci + 2 * Cj)
 *      Di = 2/6 * (Cj - Ci) / Hi
 *      Ai = Yi
 *
 *      矩阵运算采用三对角矩阵
 */
+ (NSArray *)cubicSpline:(NSArray *)splinePoints
              upperBound:(NSUInteger)upperBound
              lowerBound:(NSUInteger)lowerBound
{
    const NSUInteger pointCount = splinePoints.count;
    
    if (pointCount < 2) return splinePoints;
    
    CGFloat Ci[pointCount];
    CGFloat Hi[pointCount - 1];
    CGFloat Gradient[pointCount - 1];
    CGFloat splineMatrix[pointCount][3];
    
    Ci[0] = 0;
    
    splineMatrix[0][0] = 1;
    splineMatrix[0][1] = 0;
    splineMatrix[0][2] = 0;
    
    CGFloat * pResult = Ci + 1, * pMatrixLine = splineMatrix[1];
    for (NSInteger index = 1; index < pointCount; index++)
    {
        CGPoint curPoint = [splinePoints[index] CGPointValue];
        CGPoint prePoint = [splinePoints[index - 1] CGPointValue];
        
        if (0 == (Hi[index - 1] = curPoint.x - prePoint.x)) {
            Gradient[index - 1] = 0;
        } else {
            Gradient[index - 1] = (curPoint.y - prePoint.y) / Hi[index - 1];
        }
        
        if (index < 2) continue;
        
        *pResult = 3 * (Gradient[index - 1] - Gradient[index - 2]);
        
        pMatrixLine[1] = 2 * (Hi[index - 2] + Hi[index - 1]);
        pMatrixLine[0] = Hi[index - 2];
        pMatrixLine[2] = Hi[index - 1];
        
        pMatrixLine += 3; pResult++;
    }
    *pResult = 0; pMatrixLine[0] = 0; pMatrixLine[1] = 0; pMatrixLine[2] = 1;
    
    [self forwardElimination:pointCount splineMatrix:splineMatrix resultValues:Ci];
    
    [self backwardSubstitution:pointCount splineMatrix:splineMatrix resultValues:Ci];
    
    return [self splineInterpolation:splinePoints gradientArray:Gradient ciArray:Ci hiArray:Hi upperBound:upperBound lowerBound:lowerBound];
}


#pragma mark - spline interpolation

/**
 *  @attention
 *      Bi = Gradient_i - 1/6 * Hi * (4 * Ci + 2 * Cj)
 *      Di = 2/6 * (Cj - Ci) / Hi
 *      Ai = Yi
 *
 *      Si(X) = Ai + Bi * (X - Xi) + Ci * pow(X - Xi, 2) + Di * pow(X - Xi, 3)
 */
+ (NSArray *)splineInterpolation:(NSArray *)splinePoints
                   gradientArray:(CGFloat *)gradientArray
                         ciArray:(CGFloat *)ciArray
                         hiArray:(CGFloat *)hiArray
                      upperBound:(NSUInteger)upperBound
                      lowerBound:(NSUInteger)lowerBound
{
    if (splinePoints.count < 2) return splinePoints;
    
    NSMutableArray * outputPoints = [NSMutableArray array];
    for (NSUInteger index = 0; index < splinePoints.count - 1; index++)
    {
        CGPoint nextPoint = [splinePoints[index + 1] CGPointValue];
        CGPoint curPoint  = [splinePoints[index] CGPointValue];
        
        [outputPoints addObject:splinePoints[index]];
        
        NSUInteger aDistance = (NSUInteger)nextPoint.x - (NSUInteger)curPoint.x;
        for (NSUInteger aStep = 1; aStep < aDistance; aStep++)
        {
            CGFloat Di = (ciArray[index + 1] - ciArray[index]) / ( 3 * hiArray[index]);
            CGFloat Bi = gradientArray[index] - hiArray[index] * (2 * ciArray[index] + ciArray[index + 1]) / 3;
            
            CGFloat yValue = curPoint.y + Bi * aStep + ciArray[index] * pow(aStep, 2) + Di * pow(aStep, 3);
            
            if (yValue > upperBound) {
                yValue = upperBound;
            } else if (yValue < lowerBound) {
                yValue = lowerBound;
            }
            
            [outputPoints addObject:[NSValue valueWithCGPoint:CGPointMake(curPoint.x + aStep, yValue)]];
        }
    }
    [outputPoints addObject:splinePoints.lastObject];
    
    NSUInteger firstPointX = (NSUInteger)[outputPoints.firstObject CGPointValue].x;
    if (firstPointX > lowerBound)
    {
        NSMutableArray * lowerPoints = [NSMutableArray arrayWithCapacity:firstPointX - lowerBound];
        for (firstPointX -= 1; firstPointX >= lowerBound; firstPointX--) {
            [lowerPoints addObject:[NSValue valueWithCGPoint:CGPointMake(firstPointX, lowerBound)]];
        }
        [lowerPoints addObjectsFromArray:outputPoints];
        outputPoints = lowerPoints;
    }
    
    NSUInteger lastPointX = (NSUInteger)[outputPoints.lastObject CGPointValue].x;
    if (lastPointX < upperBound)
    {
        NSMutableArray * upperPoints = [NSMutableArray arrayWithCapacity:upperBound - lastPointX];
        for (lastPointX += 1; lastPointX <= upperBound; lastPointX++) {
            [upperPoints addObject:[NSValue valueWithCGPoint:CGPointMake(lastPointX, upperBound)]];
        }
        [outputPoints addObjectsFromArray:upperPoints];
    }
    
    return outputPoints;
}


#pragma mark - The tridiagonal matrix algorithm(TDMA)

/// 前向消元
+ (void)forwardElimination:(NSUInteger)pointCount
              splineMatrix:(CGFloat(*)[3])splineMatrix resultValues:(CGFloat *)resultValues
{
    CGFloat * pMatrixLine = splineMatrix[1];
    CGFloat * pResult     = resultValues + 1;
    for (NSUInteger index = 1; index < pointCount; index++)
    {
        CGFloat divisorVal = pMatrixLine[1] - pMatrixLine[0] * *(pMatrixLine - 1);
        if (divisorVal != 0) {
            pMatrixLine[2] = pMatrixLine[2] / divisorVal;
            *pResult = (*pResult - pMatrixLine[0] * *(pResult - 1)) / divisorVal;
        } else {
            pMatrixLine[2] = 0; *pResult = 0;
        }
        
        pMatrixLine[0] = 0;
        pMatrixLine[1] = 1;
        pMatrixLine += 3; pResult++;
    }
}

/// 后向替代
+ (void)backwardSubstitution:(NSUInteger)pointCount
                splineMatrix:(CGFloat(*)[3])splineMatrix resultValues:(CGFloat *)resultValues
{
    CGFloat * pMatrixLine = splineMatrix[pointCount - 2];
    CGFloat * pResult     = resultValues + pointCount - 2;
    for (NSInteger index = pointCount - 2; index >= 0; index--)
    {
        *pResult -= *(pResult + 1) * pMatrixLine[2];
        pMatrixLine -= 3; pResult--;
    }
}

@end
