//
//  VideoTypeSegment.m
//  theatreiphone
//
//  Created by Rong on 13-5-14.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "VideoTypeSegment.h"
enum{
    TYPE_MOVIE = 1,
    TYPE_TV = 2,
    TYPE_COMIC = 131,
    TYPE_SHOW = 3
};
@implementation VideoTypeSegment
@synthesize delegate = _delegate;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSelectButton];
    }
    return self;
}
-(void)initSelectButton{
    UIButton *movieBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    movieBtn.frame = CGRectMake(0, 0, 81, 65);
    movieBtn.tag = 100000;
    [movieBtn setBackgroundImage:[UIImage imageNamed:@"dianying.png"] forState:UIControlStateNormal];
    [movieBtn setBackgroundImage:[UIImage imageNamed:@"dianying_s.png"] forState:UIControlStateHighlighted];
    [movieBtn setBackgroundImage:[UIImage imageNamed:@"dianying_s.png"] forState:UIControlStateDisabled];
    [movieBtn addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
    movieBtn.adjustsImageWhenDisabled = NO;
    [self addSubview:movieBtn];
    
    UIButton *tvBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tvBtn.frame = CGRectMake(80, 0, 81, 65);
    tvBtn.tag = 100001;
    [tvBtn setBackgroundImage:[UIImage imageNamed:@"dianshiju.png"] forState:UIControlStateNormal];
    [tvBtn setBackgroundImage:[UIImage imageNamed:@"dianshiju_s.png"] forState:UIControlStateHighlighted];
    [tvBtn setBackgroundImage:[UIImage imageNamed:@"dianshiju_s.png"] forState:UIControlStateDisabled];
    [tvBtn addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
    tvBtn.adjustsImageWhenDisabled = NO;
    [self addSubview:tvBtn];
    
    UIButton *comicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    comicBtn.frame = CGRectMake(160, 0, 81, 65);
    comicBtn.tag = 100002;
    [comicBtn setBackgroundImage:[UIImage imageNamed:@"dongman.png"] forState:UIControlStateNormal];
    [comicBtn setBackgroundImage:[UIImage imageNamed:@"dongman_s.png"] forState:UIControlStateHighlighted];
    [comicBtn setBackgroundImage:[UIImage imageNamed:@"dongman_s.png"] forState:UIControlStateDisabled];
    [comicBtn addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
    comicBtn.adjustsImageWhenDisabled = NO;
    [self addSubview:comicBtn];
    
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showBtn.frame = CGRectMake(240, 0, 81, 65);
    showBtn.tag = 100003;
    [showBtn setBackgroundImage:[UIImage imageNamed:@"zongyi.png"] forState:UIControlStateNormal];
    [showBtn setBackgroundImage:[UIImage imageNamed:@"zongyi_s.png"] forState:UIControlStateHighlighted];
    [showBtn setBackgroundImage:[UIImage imageNamed:@"zongyi_s.png"] forState:UIControlStateDisabled];
    [showBtn addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
    showBtn.adjustsImageWhenDisabled = NO;
    [self addSubview:showBtn];
    for (int i = 0; i<3; i++) {
        UIImageView *fengexian = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fengexian _shu@2x.png"]];
        fengexian.frame = CGRectMake(80*(i+1), 0, 2, 65);
        fengexian.tag = 20000+i;
        [self addSubview:fengexian];
    }
    
}

-(void)setSelectAtIndex:(int)index{
    for (int i = 0; i < 4; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:100000+i];
        btn.enabled = YES;
    }
    UIButton *button = (UIButton *)[self viewWithTag:100000+index];
    button.enabled = NO;
}

-(void)buttonSelect:(UIButton *)btn{
    int index = 0;
    switch (btn.tag) {
        case 100000:
            index = 0;
            break;
        case 100001:
            index= 1;
            break;
        case 100002:
            index = 2;
            break;
        case 100003:
            index = 3;
            break;
            
        default:
            break;
    }
    [self setSelectAtIndex:index];
    [_delegate videoTypeSegmentDidSelectedAtIndex:index];
}

-(void)show{
    [UIView beginAnimations:@"show" context:NULL];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 65);
    UIButton *btn1 = (UIButton *)[self viewWithTag:100000];
    btn1.frame = CGRectMake(0, 0, 81, 65);
    UIButton *btn2 = (UIButton *)[self viewWithTag:100001];
    btn2.frame = CGRectMake(80, 0, 81, 65);
    UIButton *btn3 = (UIButton *)[self viewWithTag:100002];
    btn3.frame = CGRectMake(160, 0, 81, 65);
    UIButton *btn4 = (UIButton *)[self viewWithTag:100003];
    btn4.frame = CGRectMake(240, 0, 81, 65);
    
    for (int i = 0; i<3; i++){
       UIImageView *img = (UIImageView *)[self viewWithTag:20000+i];
        img.frame = CGRectMake(80*(i+1), 0, 2, 65);
    }
    [UIView setAnimationDuration:0.2];
    [UIView commitAnimations];
}

-(void)dissmiss{
    [UIView beginAnimations:@"show" context:NULL];
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 0);
    UIButton *btn1 = (UIButton *)[self viewWithTag:100000];
    btn1.frame = CGRectMake(0, 0, 81, 0);
    UIButton *btn2 = (UIButton *)[self viewWithTag:100001];
    btn2.frame = CGRectMake(80, 0, 81, 0);
    UIButton *btn3 = (UIButton *)[self viewWithTag:100002];
    btn3.frame = CGRectMake(160, 0, 81, 0);
    UIButton *btn4 = (UIButton *)[self viewWithTag:100003];
    btn4.frame = CGRectMake(240, 0, 81, 0);
    for (int i = 0; i<3; i++){
        UIImageView *img = (UIImageView *)[self viewWithTag:20000+i];
        img.frame = CGRectMake(80*(i+1), 0, 2, 0);
    }
    [UIView setAnimationDuration:0.2];
    [UIView commitAnimations];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
