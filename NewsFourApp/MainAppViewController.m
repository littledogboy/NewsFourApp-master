//
//  MainAppViewController.m
//  helloworld
//
//  Created by chen on 14/7/13.
//  Copyright (c) 2014年 chen. All rights reserved.
//

#import "MainAppViewController.h"

#import "SubViewController.h"
#import "TouchPropagatedScrollView.h"

#define MENU_HEIGHT 36
#define MENU_BUTTON_WIDTH  60

#define MIN_MENU_FONT  13.f
#define MAX_MENU_FONT  18.f

@interface MainAppViewController ()<UIScrollViewDelegate>
{
    UIView *_navView; // 自定义导航栏视图
    UIView *_topNaviV; // 顶部菜单视图

    UIScrollView *_scrollV; // 大滚动视图
    
    TouchPropagatedScrollView *_navScrollV; // 小滚动视图
    
    float _startPointX;
    UIView *_selectTabV;
}

@end

@implementation MainAppViewController

- (void)viewDidLoad
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    // 自定创建状态条
    UIView *statusBarView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, 0.f, self.view.frame.size.width, 0.f)];
    
    // 该判断是为了更改状态条的颜色
    if (isIos7 >= 7 && __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_6_1)
    {
        statusBarView.frame = CGRectMake(statusBarView.frame.origin.x, statusBarView.frame.origin.y, statusBarView.frame.size.width, 20.f);
//        statusBarView.backgroundColor = [UIColor redColor];
//        ((UIImageView *)statusBarView).backgroundColor = RGBA(212,25,38,1);
        [self.view addSubview:statusBarView];
    }

    
    //自定义导航视图（其实就是个视图）
    _navView = [[UIImageView alloc] initWithFrame:CGRectMake(0.f, StatusbarSize, self.view.frame.size.width, 44.f)];
//    _navScrollV.backgroundColor = [UIColor greenColor];
    ((UIImageView *)_navView).backgroundColor = RGBA(212,25,38,1); // 红色
    [self.view insertSubview:_navView belowSubview:statusBarView]; // 把导航视图放到了状态条的下面。（不放也行，因为是后添加的）
    _navView.userInteractionEnabled = YES;
//
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((_navView.frame.size.width - 200)/2, (_navView.frame.size.height - 40)/2, 200, 40)];
    [titleLabel setText:@"新闻列表"];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    [titleLabel setTextColor:[UIColor whiteColor]];
    [titleLabel setFont:[UIFont boldSystemFontOfSize:22]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    [_navView addSubview:titleLabel];
    
    // 自定义左button
    UIButton *lbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [lbtn setFrame:CGRectMake(10, 2, 40, 40)];
    [lbtn setTitle:@"左" forState:UIControlStateNormal];
    lbtn.layer.borderWidth = 1;
    lbtn.layer.borderColor = [UIColor whiteColor].CGColor;
    lbtn.layer.masksToBounds = YES;
    lbtn.layer.cornerRadius = 20;
    [lbtn addTarget:self action:@selector(leftAction:) forControlEvents:UIControlEventTouchUpInside]; // 注意：touchupInside 都是手指抬起来后才判定执行。
    [_navView addSubview:lbtn]; // 添加到导航视图上
    
    // 自定义右button
    UIButton *rbtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [rbtn setFrame:CGRectMake(_navView.frame.size.width - 50, 2, 40, 40)];
    [rbtn setTitle:@"右" forState:UIControlStateNormal];
    rbtn.layer.borderWidth = 1;
    rbtn.layer.borderColor = [UIColor whiteColor].CGColor;
    rbtn.layer.masksToBounds = YES;
    rbtn.layer.cornerRadius = 20;
    [rbtn addTarget:self action:@selector(rightAction:) forControlEvents:UIControlEventTouchUpInside];
    [_navView addSubview:rbtn]; // 添加到导航视图上
    
//    //MENU_HEIGHT  = 36
    // 顶部菜单视图
    _topNaviV = [[UIView alloc] initWithFrame:CGRectMake(0, _navView.frame.size.height + _navView.frame.origin.y, self.view.frame.size.width, MENU_HEIGHT)];
//    _topNaviV.backgroundColor = RGBA(236.f, 236.f, 236.f, 1);
    [self.view addSubview:_topNaviV];
    
    
    
#pragma mark--- scrollView  大滚动视图
    _scrollV = [[UIScrollView alloc] initWithFrame:CGRectMake(0, _topNaviV.frame.origin.y + _topNaviV.frame.size.height, self.view.frame.size.width, self.view.frame.size.height - _topNaviV.frame.origin.y - _topNaviV.frame.size.height)];
    [_scrollV setPagingEnabled:YES];
    _scrollV.backgroundColor = [UIColor blackColor];
//    [_scrollV setBounces:NO];
    [_scrollV setShowsHorizontalScrollIndicator:NO];
    [self.view insertSubview:_scrollV belowSubview:_navView];
    _scrollV.delegate = self; // 设置代理
    // 给平移手势 添加操作
    [_scrollV.panGestureRecognizer addTarget:self action:@selector(scrollHandlePan:)];
    
    
    // 选中视图
    _selectTabV = [[UIView alloc] initWithFrame:CGRectMake(0, _scrollV.frame.origin.y - _scrollV.frame.size.height, _scrollV.frame.size.width, _scrollV.frame.size.height)];
//    [_selectTabV setBackgroundColor:RGBA(236.f, 236.f, 236.f, 1)];
    [_selectTabV setHidden:YES]; // 一开始设置为隐藏
    [self.view insertSubview:_selectTabV belowSubview:_navView];
    
    [self createTwo];
}

- (void)createTwo
{
    // 加号按钮
    float btnW = 30;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(_topNaviV.frame.size.width - btnW, 0, btnW, MENU_HEIGHT)];
    [btn setBackgroundColor:[UIColor redColor]];
    [btn setTitle:@"+" forState:UIControlStateNormal];
    [_topNaviV addSubview:btn];
    // 添加视图
    [btn addTarget:self action:@selector(showSelectView:) forControlEvents:UIControlEventTouchUpInside];
    
    NSArray *arT = @[@"测试1", @"测试2", @"测试3", @"测试4", @"测试5", @"测试6", @"测试7", @"测试8", @"测试9", @"测试10",@"jijunl"];
    
    
#pragma mark- navScrollV 菜单滚动视图
    _navScrollV = [[TouchPropagatedScrollView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width - btnW, MENU_HEIGHT)];
    
    [_navScrollV setShowsHorizontalScrollIndicator:NO]; // 隐藏水平滚动条
    
    // 添加按钮
    for (int i = 0; i < [arT count]; i++)
    {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(MENU_BUTTON_WIDTH * i, 0, MENU_BUTTON_WIDTH, MENU_HEIGHT)];
        
        [btn setTitle:[arT objectAtIndex:i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        
        btn.tag = i + 1; // 设置tag标记值
        
        if(i==0)
        {
            [self changeColorForButton:btn red:1]; // 如果是第一个按钮，把颜色至为红色
            btn.titleLabel.font = [UIFont systemFontOfSize:MAX_MENU_FONT];
        }else
        {
            btn.titleLabel.font = [UIFont systemFontOfSize:MIN_MENU_FONT];
            [self changeColorForButton:btn red:0];
        }
        
        // 给button 添加点击事件
        [btn addTarget:self action:@selector(actionbtn:) forControlEvents:UIControlEventTouchUpInside];
        [_navScrollV addSubview:btn];
    }
    
    // 设置滚动范围
    [_navScrollV setContentSize:CGSizeMake(MENU_BUTTON_WIDTH * [arT count], MENU_HEIGHT)];
    
    [_topNaviV addSubview:_navScrollV]; // 把滚动菜单，添加到顶部菜单视图中。
    
    [self addView2Page:_scrollV count:[arT count] frame:CGRectZero];
}


// 在大滚动视图中添加对应的页面
- (void)addView2Page:(UIScrollView *)scrollV count:(NSUInteger)pageCount frame:(CGRect)frame
{
    for (int i = 0; i < pageCount; i++)
    {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(scrollV.frame.size.width * i, 0, scrollV.frame.size.width, scrollV.frame.size.height)];
        view.backgroundColor = [UIColor grayColor];
        view.tag = i + 1; // tag 值
        view.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] init];
        singleTapRecognizer.numberOfTapsRequired = 1;
        [singleTapRecognizer addTarget:self action:@selector(pust2View:)];
        [view addGestureRecognizer:singleTapRecognizer]; // 添加轻拍手势
        
        [self initPageView:view];
        
        [scrollV addSubview:view];
    }
    [scrollV setContentSize:CGSizeMake(scrollV.frame.size.width * pageCount, scrollV.frame.size.height)];
}

//写入方框
- (void)initPageView:(UIView *)view
{
    int width = (view.frame.size.width - 20)/3;
    float x = 5;
    float y = 4;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 10, self.view.frame.size.width, self.view.frame.size.height - 64)];
    int sumJ = (int)(1+arc4random()%4);
    int sumI = (int)(1+arc4random()%3);
    for (int j = 1; j <= sumJ; j++)
    {
        for (int i = 1; i <= 3; i++)
        {
            if (j == sumJ && i > sumI)
            {
                break;
            }
            float w = x * i + width * (i - 1);
            float h = y * j + width * (j - 1);
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(w, h, width, width)];
            [l setBackgroundColor:[QHCommonUtil getRandomColor]];
            [v addSubview:l];
        }
    }
    
    [view addSubview:v];
}
//滑动  scorrView  显示 红色大字
- (void)changeView:(float)x
{
    



    // x 为大视图的x偏移量
    // xx 为menu的偏移量
    float xx = x * (MENU_BUTTON_WIDTH / self.view.frame.size.width);
    //获取 对于 button来说 的 偏移量
    float startX = xx; // 起始startX = menu偏移量
//    float endX = xx + MENU_BUTTON_WIDTH;
    
    //获取 View 的 tag值 偏移量/ 宽度 + 1 1 2 3 4
    int sT = (x)/_scrollV.frame.size.width + 1;
    NSLog(@"tag = %d",sT);
//    NSLog(@"x = %f  xx %f  starX = %f ST = %d",x,xx,startX,sT);
    if (sT <= 0) //
    {
        return; // tag值不会为0的
    }
    
    //获取当前VIEW 的button
    //#define MENU_HEIGHT 36
    //#define MENU_BUTTON_WIDTH  60
    //
    //#define MIN_MENU_FONT  13.f
    //#define MAX_MENU_FONT  18.f
    // 获取button1 根据view的tag来获取对应的button
    UIButton *btn = (UIButton *)[_navScrollV viewWithTag:sT]; // 获取tag值对应的button
    
    //获取 占button的百分比
    //  获取相对某个button的偏移量 ，某个button偏移量 = 总偏移量 - button宽度 * （tag -1）
    CGFloat oneViewOffset = startX - MENU_BUTTON_WIDTH * (sT - 1); // menu相对某个button的偏移量
    //获取 偏移量在button 的宽度的百分比
    float percent = oneViewOffset/MENU_BUTTON_WIDTH; // 偏移量相对button的百分比
    NSLog(@" percent = %f",percent);
    
    //根据偏移量百分比  改变 字体 的 型号
    float value = [QHCommonUtil lerp:(1 - percent) min:MIN_MENU_FONT max:MAX_MENU_FONT];
    btn.titleLabel.font = [UIFont systemFontOfSize:value];
    [self changeColorForButton:btn red:(1 - percent)]; // 改变颜色，根据1-偏移量百分比更改btn颜色。
//
//    if((int)xx%MENU_BUTTON_WIDTH == 0)
//        return;
    // 获取button2 更改button2的字体 和 字体颜色
    UIButton *btn2 = (UIButton *)[_navScrollV viewWithTag:sT + 1];
    float value2 = [QHCommonUtil lerp:percent min:MIN_MENU_FONT max:MAX_MENU_FONT];
    btn2.titleLabel.font = [UIFont systemFontOfSize:value2];
    [self changeColorForButton:btn2 red:percent];
}

- (void)changeColorForButton:(UIButton *)btn red:(float)nRedPercent
{
    float value = [QHCommonUtil lerp:nRedPercent min:0 max:212];
    [btn setTitleColor:RGBA(value,25,38,1) forState:UIControlStateNormal];
}

#pragma mark - action

- (void)actionbtn:(UIButton *)btn
{
    [_scrollV scrollRectToVisible:CGRectMake(_scrollV.frame.size.width * (btn.tag - 1), _scrollV.frame.origin.y, _scrollV.frame.size.width, _scrollV.frame.size.height) animated:YES];
    
    float xx = _scrollV.frame.size.width * (btn.tag - 1) * (MENU_BUTTON_WIDTH / self.view.frame.size.width) - MENU_BUTTON_WIDTH;
    [_navScrollV scrollRectToVisible:CGRectMake(xx, 0, _navScrollV.frame.size.width, _navScrollV.frame.size.height) animated:YES];
}

- (void)leftAction:(UIButton *)btn
{
    if ([_selectTabV isHidden] == NO)
    {
        [self showSelectView:btn];
        return;
    }
    [[QHSliderViewController sharedSliderController] showLeftViewController];
}

- (void)rightAction:(UIButton *)btn
{
    if ([_selectTabV isHidden] == NO)
    {
        [self showSelectView:btn];
        return;
    }
    [[QHSliderViewController sharedSliderController] showRightViewController];
}

- (void)showSelectView:(UIButton *)btn
{
    if ([_selectTabV isHidden] == YES)
    {
        [_selectTabV setHidden:NO];
        [UIView animateWithDuration:0.6 animations:^
         {
             [_selectTabV setFrame:CGRectMake(0, _scrollV.frame.origin.y, _scrollV.frame.size.width, _scrollV.frame.size.height)];
         } completion:^(BOOL finished)
         {
         }];
    }else
    {
        [UIView animateWithDuration:0.6 animations:^
         {
             [_selectTabV setFrame:CGRectMake(0, _scrollV.frame.origin.y - _scrollV.frame.size.height, _scrollV.frame.size.width, _scrollV.frame.size.height)];
         } completion:^(BOOL finished)
         {
             [_selectTabV setHidden:YES];
         }];
    }
}

-(void)scrollHandlePan:(UIPanGestureRecognizer*) panParam
{
    BOOL isPaning = NO;
    if(_scrollV.contentOffset.x < 0)
    {
        isPaning = YES;
//        isLeftDragging = YES;
//        [self showMask];
    }
    else if(_scrollV.contentOffset.x > (_scrollV.contentSize.width - _scrollV.frame.size.width))
    {
        isPaning = YES;
//        isRightDragging = YES;
//        [self showMask];
    }
    if(isPaning)
    {
        [[QHSliderViewController sharedSliderController] moveViewWithGesture:panParam];
    }
}

- (void)pust2View:(UITapGestureRecognizer *)tap
{
    CGPoint point = [tap locationInView:_scrollV];
    int t = point.x/_scrollV.frame.size.width + 1;
    SubViewController *subViewController = [[SubViewController alloc] initWithFrame:[UIScreen mainScreen].bounds andSignal:@""];
    subViewController.szSignal = [NSString stringWithFormat:@"%d--%d", t, 1];
    
    [[QHSliderViewController sharedSliderController].navigationController pushViewController:subViewController animated:YES];
}

#pragma mark - UIScrollViewDelegate

// 将要开始拖动
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _startPointX = scrollView.contentOffset.x;
}

// 发生滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self changeView:scrollView.contentOffset.x]; // 滚动视图的时候，更改字体大小，更改颜色。
}

// 已经滚动停止
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    // 滚动停止后，让上方的菜单栏也滚动
    
    // xx偏移量 = scrollV.偏移量x * (菜单按钮宽度 / scrollV的官渡)
    // 小滚动视图偏移量 = 大滚动视图偏移量 * （按钮宽度 与 大滚动宽度 比例）
    // 滚动的比例是一样的 = 大偏移/大宽 = 小偏移/小宽  那么 小偏移 = 大偏移/大宽 * 小宽
    
    float xx = scrollView.contentOffset.x * (MENU_BUTTON_WIDTH / self.view.frame.size.width) - MENU_BUTTON_WIDTH;
    
    // 该方法真妙！！ = W = 
    // 将scrollView坐标系内的一块指定区域移到scrollView的窗口中，如果这部分已经存在于窗口中，则什么也不做。
    [_navScrollV scrollRectToVisible:CGRectMake(xx, 0, _navScrollV.frame.size.width, _navScrollV.frame.size.height) animated:YES];
}

@end
