//
//  CustomActionSheet.m
//  yueshipin
//
//  Created by lily on 13-7-18.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CustomActionSheet.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomActionSheet
@synthesize delegate = delegate_;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
-(void)initCustomActionSheet{
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
    self.frame = win.frame;
    self.backgroundColor = [UIColor clearColor];
    
    UIView *bg = [[UIView alloc] initWithFrame:self.frame];
    bg.backgroundColor = [UIColor blackColor];
    bg.alpha = 0.5;
    [self addSubview:bg];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeSelf)];
    tapGesture.numberOfTapsRequired = 1;
    tapGesture.numberOfTouchesRequired = 1;
    [bg addGestureRecognizer:tapGesture];
    
    UIImageView *actionSheetBg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 315, 124)];
    actionSheetBg.center = self.center;
    actionSheetBg.userInteractionEnabled = YES;
    actionSheetBg.backgroundColor = [UIColor blackColor];
    actionSheetBg.transform = CGAffineTransformMakeRotation(-M_PI/2);
    actionSheetBg.layer.cornerRadius = 5;
    actionSheetBg.alpha = 0.7;
    [self addSubview:actionSheetBg];
    
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 315, 34)];
    title.textAlignment = NSTextAlignmentCenter;
    title.backgroundColor = [UIColor clearColor];
    title.layer.cornerRadius = 5;
    title.text = @"打开方式：";
    title.font = [UIFont boldSystemFontOfSize:17];
    title.textColor = [UIColor whiteColor];
    [actionSheetBg addSubview:title];
    
    UIButton *button1 = [[UIButton alloc] initWithFrame:CGRectMake(5, 34, 305, 40)];
    button1.tag = 12000;
    button1.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button1 addTarget:self action:@selector(buttonPressd:) forControlEvents:UIControlEventTouchUpInside];
    [button1 setTitle:@"本地播放器" forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button1 setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [button1 setBackgroundColor:[UIColor blackColor]];
    button1.titleEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    button1.layer.cornerRadius = 5;
    [actionSheetBg addSubview:button1];
    
    UIButton *button2 = [[UIButton alloc] initWithFrame:CGRectMake(5, 79, 305, 40)];
    button2.tag = 12001;
    button2.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [button2 addTarget:self action:@selector(buttonPressd:) forControlEvents:UIControlEventTouchUpInside];
    [button2 setTitle:@"悦视频TV版" forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button2 setTitleColor:[UIColor orangeColor] forState:UIControlStateHighlighted];
    [button2 setBackgroundColor:[UIColor blackColor]];
    button2.layer.cornerRadius = 5;
    [actionSheetBg addSubview:button2];
    
}
-(void)actionSheetShow{
    if (self) {
        UIWindow *win = [[UIApplication sharedApplication] keyWindow];
        [win addSubview:self];
    }
}
-(void)actionSheetHidde{
    if (self) {
        [self removeFromSuperview];
    }
}
-(void)buttonPressd:(UIButton *)btn{
    switch (btn.tag) {
        case 12000:{
            if ([delegate_ respondsToSelector:@selector(CustomActionSheetDelegateDidSelectAtIndex:)]) {
                [delegate_ CustomActionSheetDelegateDidSelectAtIndex:0];
            }
            break;
        }
        case 12001:{
            if ([delegate_ respondsToSelector:@selector(CustomActionSheetDelegateDidSelectAtIndex:)]) {[delegate_ CustomActionSheetDelegateDidSelectAtIndex:1];
            }
            break;
        }
        default:
            break;
    }
    [self actionSheetHidde];
}

-(void)removeSelf{
[self actionSheetHidde];
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
