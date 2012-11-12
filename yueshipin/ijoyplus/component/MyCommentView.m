//
//  MyCommentView.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MyCommentView.h"
#import <QuartzCore/QuartzCore.h>

@implementation MyCommentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

- (void)drawRect:(CGRect)rect
{
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
}

@end
