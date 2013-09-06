//
//  YueSearchView.m
//  yueshipin
//
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "YueSearchView.h"

#define ORANGE_COLOR    ([UIColor colorWithRed:249.0/255.0 green:165.0/255.0 blue:67.0/255.0 alpha:1.0])
#define GRAY_COLOR      ([UIColor colorWithRed:132.0/255.0 green:132.0/255.0 blue:132.0/255.0 alpha:1.0])

#define FONT_SIZE_INTERVAL  (6)


@interface YueSearchView ()
@property (nonatomic, strong) NSMutableArray * locationInfo;
@property (nonatomic, strong) NSArray *         colors;
@property BOOL isTap;
@property CGPoint beginPoint;
- (void)initPointInfo;
@end

@implementation YueSearchView
@synthesize colors,locationInfo,info = _info,beginPoint,delegate,isTap;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        locationInfo = [[NSMutableArray alloc] init];
        colors = [NSArray arrayWithObjects:ORANGE_COLOR,GRAY_COLOR, nil];
        [self initPointInfo];
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - private
- (void)initPointInfo
{
    NSArray * firstP = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:CGPointMake(140, 115)],
                        [NSValue valueWithCGPoint:CGPointMake(110, 245)],
                        [NSValue valueWithCGPoint:CGPointMake(245, 180)],
                        [NSValue valueWithCGPoint:CGPointMake(210, 285)],
                        [NSValue valueWithCGPoint:CGPointMake(430, 270)],
                        [NSValue valueWithCGPoint:CGPointMake(460, 110)],
                        [NSValue valueWithCGPoint:CGPointMake(655, 90)],
                        [NSValue valueWithCGPoint:CGPointMake(515, 225)],
                        [NSValue valueWithCGPoint:CGPointMake(600, 275)],
                        [NSValue valueWithCGPoint:CGPointMake(430, 385)], nil];
    
    NSArray * secondP = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:CGPointMake(350, 80)],
                        [NSValue valueWithCGPoint:CGPointMake(170, 155)],
                        [NSValue valueWithCGPoint:CGPointMake(360, 149)],
                        [NSValue valueWithCGPoint:CGPointMake(580, 155)],
                        [NSValue valueWithCGPoint:CGPointMake(280, 220)],
                        [NSValue valueWithCGPoint:CGPointMake(515, 225)],
                        [NSValue valueWithCGPoint:CGPointMake(130, 275)],
                        [NSValue valueWithCGPoint:CGPointMake(340, 285)],
                        [NSValue valueWithCGPoint:CGPointMake(240, 360)],
                        [NSValue valueWithCGPoint:CGPointMake(430, 325)], nil];
    
    NSArray * thirdP  = [NSArray arrayWithObjects:
                        [NSValue valueWithCGPoint:CGPointMake(170, 115)],
                        [NSValue valueWithCGPoint:CGPointMake(460, 90)],
                        [NSValue valueWithCGPoint:CGPointMake(310, 210)],
                        [NSValue valueWithCGPoint:CGPointMake(130, 235)],
                        [NSValue valueWithCGPoint:CGPointMake(540, 195)],
                        [NSValue valueWithCGPoint:CGPointMake(200, 180)],
                        [NSValue valueWithCGPoint:CGPointMake(480, 260)],
                        [NSValue valueWithCGPoint:CGPointMake(160, 350)],
                        [NSValue valueWithCGPoint:CGPointMake(380, 285)],
                        [NSValue valueWithCGPoint:CGPointMake(560, 360)], nil];
    
    [locationInfo addObject:firstP];
    [locationInfo addObject:secondP];
    [locationInfo addObject:thirdP];
    
}

#pragma mark - interface
- (void)setInfo:(NSMutableArray *)info
{
    _info = info;
    int index = arc4random() % locationInfo.count;
    NSArray * pointArray = [locationInfo objectAtIndex:index];
    for (int i = 0; i < info.count; i ++)
    {
        NSString * name = [info objectAtIndex:i];
        
        CGPoint point = [[pointArray objectAtIndex:i] CGPointValue];
        NSInteger fontSize = arc4random()%FONT_SIZE_INTERVAL + 12;
        CGSize size = [name sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        
        UIButton * btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.backgroundColor = [UIColor clearColor];
        btn.frame = CGRectMake(point.x, point.y, size.width + 65, size.height+30);
        [btn setTitle:name forState:UIControlStateNormal];
        UIColor * color = [colors objectAtIndex:arc4random()%2];
        [btn setTitleColor:color forState:UIControlStateNormal];
        [btn setTitleColor:color forState:UIControlStateSelected];
        [btn setTitleColor:color forState:UIControlStateHighlighted];
        [btn addTarget:self
                action:@selector(btnClick:)
      forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
    }
}

- (void)btnClick:(id)sender
{
    UIButton * btn = (UIButton *)sender;
    if (delegate && [delegate respondsToSelector:@selector(keyWordClicked:)])
    {
        [delegate keyWordClicked:btn.titleLabel.text];
    }
}

#pragma mark - touch event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    beginPoint = [touch locationInView:self];
    isTap = YES;
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    isTap = NO;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint curPoint = [touch locationInView:self];
    if (isTap)
    {
        if (delegate && [delegate respondsToSelector:@selector(showNextPage)])
        {
            [delegate showNextPage];
        }
    }
    else
    {
        if (abs(curPoint.x - beginPoint.x) > 40
            || abs(curPoint.y - beginPoint.y) > 40)
        {
            if (delegate && [delegate respondsToSelector:@selector(showNextPage)])
            {
                [delegate showNextPage];
            }
        }
    }

}

@end
