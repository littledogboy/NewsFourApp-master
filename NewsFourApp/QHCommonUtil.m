//
//  QHCommonUtil.m
//  NewsFourApp
//
//  Created by chen on 14/8/9.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "QHCommonUtil.h"

@implementation QHCommonUtil

+ (UIImage *)getImageFromView:(UIView *)view
{
    UIGraphicsBeginImageContext(view.bounds.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIColor *)getRandomColor
{
    return [UIColor colorWithRed:(float)(1+arc4random()%99)/100 green:(float)(1+arc4random()%99)/100 blue:(float)(1+arc4random()%99)/100 alpha:1];
}

/*0--1 : lerp( float percent, float x, float y ){ return x + ( percent * ( y - x ) ); };*/
+ (float)lerp:(float)percent min:(float)nMin max:(float)nMax
{
    // 百分比乘以字号，或者百分比乘以color
    //字号
    float result = nMin;
    //当 percent = 1 时 最大  值是 nMax - nMin  percent = 0 是最小 为0
    float change = percent *(nMax - nMin);
    // 最小值 加上  偏移量 * (最大值  - 最小值)
    result = nMin + change;
    
    return result;
}

@end
