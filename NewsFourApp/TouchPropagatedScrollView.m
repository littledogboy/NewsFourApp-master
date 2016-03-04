//
//  TouchPropagatedScrollView.m
//
//  Created by chen on 14/7/13.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "TouchPropagatedScrollView.h"

@implementation TouchPropagatedScrollView

// 当滚动touchProgatedScrollView的时候，触摸点不会被分配到子视图上
- (BOOL)touchesShouldCancelInContentView:(UIView *)view
{
	return YES;
}

@end
