//
//  CloseTipsView.m
//  yueshipin
//
//  Created by 08 on 13-3-19.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CloseTipsView.h"

@interface CloseTipsView (private)

@end

@implementation CloseTipsView
#pragma mark -
#pragma mark - init method
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = NO;
        
//        CGRect frame = self.frame;
//        UIImageView * bgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
//        UIImage * img = [[UIImage imageNamed:@"fading.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 5, 0, 5)];
//        bgView.image = img;
//        [self addSubview:bgView];
        
        UIImageView * arrow = [[UIImageView alloc] initWithFrame:CGRectMake(335, self.frame.size.height - 29,10, 7.5)];
        arrow.image = [UIImage imageNamed:@"arrow.png"];
        [self addSubview:arrow];
        
        UILabel * tips = [[UILabel alloc] initWithFrame:CGRectMake(350, self.frame.size.height - 40,150, 30)];
        tips.textAlignment = UITextAlignmentLeft;
        tips.text = @"向右滑动可关闭窗口";
        tips.font = [UIFont systemFontOfSize:14.0];
        tips.textColor = [UIColor lightGrayColor];
        tips.backgroundColor = [UIColor clearColor];
        [self addSubview:tips];
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    
}

@end
