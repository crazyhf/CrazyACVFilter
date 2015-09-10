//
//  CrazyCubicSpline.h
//  CrazyACVFilter
//
//  Created by crazylhf on 15/9/10.
//  Copyright (c) 2015年 crazylhf. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  @brief
 *      Cubic Spline Interpolation推导结果:
 *      X ∊ (Xi, Xj, Xk, ... , Xn) , (j = i + 1, k = i + 2) ; 一阶导Si'(X) 和 二阶导Si''(X) 在区间上函数连续
 *
 *      X ∊ [Xi, Xj]时, 有以下三次样条曲线关系:
 *      Si(X)   = Ai + Bi * (X - Xi) + Ci * pow(X - Xi, 2) + Di * pow(X - Xi, 3)
 *      Si'(X)  = Bi + 2 * Ci * (X - Xi) + 3 * Di * pow(X - Xi, 2)
 *      Si''(X) = 2 * Ci + 6 * Di * (X - Xi)
 *
 *      X = Xi 时, Si(Xi) = Ai = Yi
 *      X = Xj 时, Si(Xj) = Ai + Bi * (Xj - Xi) + Ci * pow(Xj - Xi, 2) + Di * pow(Xj - Xi, 3) = Yj
 *
 *      在 X = Xj 处,
 *      Si'(Xj) = Sj'(Xj)   => Bi + 2 * Ci * (Xj - Xi) + 3 * Di * pow(Xj - Xi, 2) = Bj
 *      Si''(Xj) = Sj''(Xj) => 2 * Ci + 6 * Di * (Xj - Xi) = 2 * Cj
 *
 *      Ai , Bi , Ci , Di 的推导结果:
 *      Ai = Yi
 *      Bi = (Yj - Yi) / (Xj - Xi) - 1/6 * (Xj - Xi) * (4 * Ci + 2 * Cj)
 *      Di = 2/6 * (Cj - Ci) / (Xj - Xi)
 *
 *      (Yj - Yi) / (Xj - Xi) + 1/6 * (Xj - Xi) * (2 * Ci + 4 * Cj) = Bj
 *      令 Hi = Xj - Xi , Hj = Xk - Xj ,
 *      3 * ((Yk - Yj) / Hj - (Yj - Yi) / Hi) = Hi * Ci + (Hi + Hj) * 2 * Cj + Hj * Ck
 */
@interface CrazyCubicSpline : NSObject

+ (NSArray *)cubicSpline:(NSArray *)splinePoints
              upperBound:(NSUInteger)upperBound
              lowerBound:(NSUInteger)lowerBound;

@end
