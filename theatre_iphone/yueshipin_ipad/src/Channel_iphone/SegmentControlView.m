//
//  SegmentControlView.m
//  theatreiphone
//
//  Created by Rong on 13-5-13.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "SegmentControlView.h"
@implementation SegmentControlView
@synthesize seg = _seg;
@synthesize movieLabelArr = _movieLabelArr;
@synthesize tvLabelArr = _tvLabelArr;
@synthesize comicLabelArr = _comicLabelArr;
@synthesize showLabelArr = _showLabelArr;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _movieLabelArr = [NSArray arrayWithObjects:@"全部",@"美国",@"动作",@"科幻",@"爱情",@"更多",nil];
        _tvLabelArr = [NSArray arrayWithObjects:@"全部",@"美国",@"韩国",@"日本",@"香港",@"更多",nil];
        _comicLabelArr = [NSArray arrayWithObjects:@"全部",@"日本",@"欧美",@"国产",@"热血",@"更多",nil];
        _showLabelArr = [NSArray arrayWithObjects:@"全部",@"综艺",@"选秀",@"情感",@"访谈",@"更多",nil];
        
        UIView *segmentBg = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 42)];
        segmentBg.backgroundColor = [UIColor grayColor];
        [self addSubview:segmentBg];
        
        _seg = [[UISegmentedControl alloc] initWithItems:_movieLabelArr];
        _seg.frame = CGRectMake(0, 0, 306, 30);
        _seg.center = segmentBg.center;
        _seg.selectedSegmentIndex = 0;
        [self addSubview:_seg];
    }
    return self;
}
-(void)setSegmentControl:(int)type{
    if (_seg) {
        [_seg removeFromSuperview];
         _seg = nil;
    }
    switch (type) {
        case TYPE_MOVIE:
            _seg = [[UISegmentedControl alloc] initWithItems:_movieLabelArr];
            break;
        case TYPE_TV:
            _seg = [[UISegmentedControl alloc] initWithItems:_tvLabelArr];
            break;
        case TYPE_COMIC:
            _seg = [[UISegmentedControl alloc] initWithItems:_comicLabelArr];
            break;
        case TYPE_SHOW:
            _seg = [[UISegmentedControl alloc] initWithItems:_showLabelArr];
            break;
            
        default:
            break;
    }
    _seg.frame = CGRectMake(0, 0, 306, 30);
    _seg.center = CGPointMake(160, 21);
    _seg.selectedSegmentIndex = 0;
    [self addSubview:_seg];

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
