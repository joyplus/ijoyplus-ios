//
//  LeveyPopListView.m
//  LeveyPopListViewDemo
//
//  Created by Levey on 2/21/12.
//  Copyright (c) 2012 Levey. All rights reserved.
//

#import "DeviceListView.h"

#define WIDTH 200
#define HEIGHT 145

#define POPLISTVIEW_SCREENINSET_Y 45.
#define POPLISTVIEW_HEADER_HEIGHT 35.
#define RADIUS 10.

@interface DeviceListView (private)
- (void)fadeIn;
- (void)fadeOut;
@end

@implementation DeviceListView
@synthesize delegate;
#pragma mark - initialization & cleaning up
- (id)initWithTitle:(NSString *)aTitle
{
    if (self = [super initWithFrame:CGRectMake(0, 0, 560, 320)])
    {
        self.backgroundColor = [UIColor clearColor];
        self.autoresizesSubviews = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _title = [[UILabel alloc] initWithFrame:CGRectZero];
        _title.text = aTitle;
        [_title sizeToFit];
        _title.font = [UIFont boldSystemFontOfSize:15];
        _title.backgroundColor = [UIColor clearColor];
        _title.textColor = [UIColor whiteColor];
        CGRect frame = [UIScreen mainScreen].applicationFrame;
        _title.center = CGPointMake(frame.size.height/2, POPLISTVIEW_SCREENINSET_Y + 15);
        [self addSubview:_title];
        tableViewController = [[DeviceListViewController alloc] init];
        tableViewController.view.frame = CGRectMake((frame.size.height - WIDTH)/2 + 1, POPLISTVIEW_SCREENINSET_Y + POPLISTVIEW_HEADER_HEIGHT + 1, WIDTH - 2, HEIGHT - POPLISTVIEW_HEADER_HEIGHT - 10);
        [self addSubview:tableViewController.view];
        
        _footerImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"table_footer"]];
        _footerImage.frame = CGRectMake(tableViewController.view.frame.origin.x, tableViewController.view.frame.origin.y + tableViewController.view.frame.size.height, WIDTH - 2, 8);
        [self addSubview:_footerImage];
    }
    return self;
}

#pragma mark - Private Methods
- (void)fadeIn
{
    self.transform = CGAffineTransformMakeScale(1.3, 1.3);
    self.alpha = 0;
    [UIView animateWithDuration:.35 animations:^{
        self.alpha = 1;
        self.transform = CGAffineTransformMakeScale(1, 1);
    }];
    
}
- (void)fadeOut
{
    [UIView animateWithDuration:.35 animations:^{
        self.transform = CGAffineTransformMakeScale(1.3, 1.3);
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self removeFromSuperview];
        }
    }];
}

#pragma mark - Instance Methods
- (void)showInView:(UIView *)aView animated:(BOOL)animated
{
    [aView addSubview:self];
    if (animated) {
        [self fadeIn];
    }
}

#pragma mark - TouchTouchTouch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // tell the delegate the cancellation
    if (self.delegate && [self.delegate respondsToSelector:@selector(leveyPopListViewDidCancel)]) {
        [self.delegate leveyPopListViewDidCancel];
    }
    
    // dismiss self
    [self fadeOut];
}

#pragma mark - DrawDrawDraw
- (void)drawRect:(CGRect)rect
{
    CGRect frame = [UIScreen mainScreen].applicationFrame;
    float x = (frame.size.height - WIDTH)/2;
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Draw the background with shadow
    CGContextSetShadowWithColor(ctx, CGSizeZero, 6., [UIColor colorWithWhite:0 alpha:.7].CGColor);
    [[UIColor colorWithRed:39/255.0 green:53/255.0 blue:54/255.0 alpha:.5] setFill];
    
    float y = POPLISTVIEW_SCREENINSET_Y;
    CGMutablePathRef path = CGPathCreateMutable();
	CGPathMoveToPoint(path, NULL, x, y + RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y, x + RADIUS, y, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + WIDTH, y, x + WIDTH, y + RADIUS, RADIUS);
	CGPathAddArcToPoint(path, NULL, x + WIDTH, y + HEIGHT, x + WIDTH - RADIUS, y + HEIGHT, RADIUS);
	CGPathAddArcToPoint(path, NULL, x, y + HEIGHT, x, y + HEIGHT - RADIUS, RADIUS);
	CGPathCloseSubpath(path);
	CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    
    CGRect separatorRect = CGRectMake(x, POPLISTVIEW_SCREENINSET_Y + POPLISTVIEW_HEADER_HEIGHT - 2,
                                      WIDTH, 2);
    
    // Draw the title and the separator with shadow
    CGContextSetShadowWithColor(ctx, CGSizeMake(0, 1), 0.5f, [UIColor blackColor].CGColor);
    [[UIColor colorWithRed:46/255.0 green:112/255.0 blue:156/255.0 alpha:1.] setFill];
    //    [_title drawInRect:titleRect withFont:[UIFont boldSystemFontOfSize:15.]];
    CGContextFillRect(ctx, separatorRect);
}

@end
