//
//  VideoTypeSegment.m
//  theatreiphone
//
//  Created by Rong on 13-5-14.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "VideoTypeSegment.h"
enum{
    TYPE_MOVIE,
    TYPE_TV,
    TYPE_COMIC,
    TYPE_SHOW
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
    movieBtn.frame = CGRectMake(0, 0, 80, 65);
    movieBtn.tag = 100+TYPE_MOVIE;
    [movieBtn addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
    movieBtn.enabled = NO;
    movieBtn.adjustsImageWhenDisabled = NO;
    [self addSubview:movieBtn];
    
    UIButton *tvBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    tvBtn.frame = CGRectMake(0, 80, 80, 65);
    tvBtn.tag = 100+TYPE_TV;
    [tvBtn addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
    tvBtn.enabled = NO;
    tvBtn.adjustsImageWhenDisabled = NO;
    [self addSubview:tvBtn];
    
    UIButton *comicBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    comicBtn.frame = CGRectMake(0, 160, 80, 65);
    comicBtn.tag = 100+TYPE_COMIC;
    [comicBtn addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
    comicBtn.enabled = NO;
    comicBtn.adjustsImageWhenDisabled = NO;
    [self addSubview:comicBtn];
    
    UIButton *showBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    showBtn.frame = CGRectMake(0, 240, 80, 65);
    showBtn.tag = 100+TYPE_SHOW;
    [showBtn addTarget:self action:@selector(buttonSelect:) forControlEvents:UIControlEventTouchUpInside];
    showBtn.enabled = NO;
    showBtn.adjustsImageWhenDisabled = NO;
    [self addSubview:showBtn];

}

-(void)setSelectAtIndex:(int)index{
    for (int i = 0; i < 4; i++) {
        UIButton *btn = (UIButton *)[self viewWithTag:100+i];
        btn.enabled = YES;
    }
    UIButton *button = (UIButton *)[self viewWithTag:100+index];
    button.enabled = NO;
}

-(void)buttonSelect:(UIButton *)btn{
    int index = btn.tag - 100;
    [self setSelectAtIndex:index];
    [_delegate segmentDidSelectedAtIndex:index];
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
