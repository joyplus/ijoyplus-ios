//
//  IntroductionView.m
//  yueshipin
//
//  Created by Rong on 13-4-15.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "IntroductionView.h"
#import "CommonMotheds.h"
@implementation IntroductionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initIntroductionView];
        self.backgroundColor = [UIColor whiteColor];
    }
    return self;
}
-(void)initIntroductionView{
    CGSize size = [UIApplication sharedApplication].delegate.window.bounds.size;
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
    scrollView.contentSize = CGSizeMake(size.width*4, size.height);
    scrollView.pagingEnabled = YES;
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.delegate = self;
    //scrollView.bounces = NO;
    
    if (size.height == 568) {
        UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduction_iphone5_1@2x.jpg"]];
        imageView1.frame = CGRectMake(0, 20, size.width, size.height-20);
        [scrollView addSubview:imageView1];
        UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduction_iphone5_2@2x.jpg"]];
        imageView2.frame = CGRectMake(size.width, 20, size.width, size.height-20);
        [scrollView addSubview:imageView2];
        UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduction_iphone5_3@2x.jpg"]];
        imageView3.frame = CGRectMake((size.width)*2, 20, size.width, size.height-20);
        [scrollView addSubview:imageView3];
        UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introduction_iphone5_4@2x.jpg"]];
        imageView4.frame = CGRectMake((size.width)*3, 20, size.width, size.height-20);
        imageView4.userInteractionEnabled = YES;
        [scrollView addSubview:imageView4];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.alpha = 0.5;
        btn.backgroundColor = [UIColor clearColor];
        btn.frame = CGRectMake(230, 513, 75, 25);
        [btn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        [imageView4 addSubview:btn];
        [self addSubview:scrollView];
    }
    else{
        UIImageView *imageView1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introductioniphone4_1@2x.jpg"]];
        imageView1.frame = CGRectMake(0, 20, size.width, size.height-20);
        [scrollView addSubview:imageView1];
        UIImageView *imageView2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introductioniphone4_2@2x.jpg"]];
        imageView2.frame = CGRectMake(size.width, 20, size.width, size.height-20);
        [scrollView addSubview:imageView2];
        UIImageView *imageView3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introductioniphone4_3@2x.jpg"]];
        imageView3.frame = CGRectMake((size.width)*2, 20, size.width, size.height-20);
        [scrollView addSubview:imageView3];
        UIImageView *imageView4 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"introductioniphone4_4@2x.jpg"]];
        imageView4.frame = CGRectMake((size.width)*3, 20, size.width, size.height-20);
        imageView4.userInteractionEnabled = YES;
        [scrollView addSubview:imageView4];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        btn.frame = CGRectMake(230, 416, 75, 25);
        [btn addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
        [imageView4 addSubview:btn];
        [self addSubview:scrollView];
        [self addSubview:scrollView];
    }
    
}

-(void)show{
    [[UIApplication sharedApplication].delegate.window addSubview:self];

}
-(void)next{
   [CommonMotheds setVersion];
   
    [self disAppearAnimation];
}
-(void)disAppearAnimation{
     CGSize size = [UIApplication sharedApplication].delegate.window.bounds.size;
    
    [UIView beginAnimations:nil context:nil];
    //动画持续时间
    [UIView setAnimationDuration:0.4];
    //设置动画的回调函数，设置后可以使用回调方法
    [UIView setAnimationDelegate:self];
    //设置动画曲线，控制动画速度
    self.alpha = 0;
    self.frame = CGRectMake(-size.width, 0,size.width , size.height);
    
    [UIView  setAnimationCurve: UIViewAnimationCurveEaseInOut];
    //设置动画方式，并指出动画发生的位置
    [UIView setAnimationDidStopSelector:@selector(hidden)];
    //提交UIView动画
    [UIView commitAnimations];

}
-(void)hidden{
 self.hidden = YES;
}
#pragma mark -
#pragma mark ScrollViewDelegate Methods
-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
        
}


- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    
    CGFloat pageWidth = self.frame.size.width;
     CGPoint offset = scrollView.contentOffset;
    int page = offset.x/pageWidth;
    if (page == 3 && offset.x > 0) {
        [self next];
       
    }
    
}


@end
