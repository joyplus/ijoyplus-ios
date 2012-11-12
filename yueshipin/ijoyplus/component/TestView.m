//
//  TestView.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-13.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "TestView.h"
#import <QuartzCore/QuartzCore.h>

@implementation TestView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self addShadow];
        [self addGrayGradientShadow];
    }
    return self;
}

-(void)addShadow{
    
    self.layer.shadowOpacity = 0.4;
    self.layer.shadowRadius = 0.9;
    self.layer.shadowOffset = CGSizeMake(0, 0);
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    CGPoint p1 = CGPointMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.height);
    CGPoint p2 = CGPointMake(self.frame.origin.x+self.frame.size.width, p1.y);
    CGPoint c1 = CGPointMake((p1.x+p2.x)/4 , p1.y+6.0);
    CGPoint c2 = CGPointMake(c1.x*3, c1.y);
    
    [path moveToPoint:p1];
    [path addCurveToPoint:p2 controlPoint1:c1 controlPoint2:c2];
    
    self.layer.shadowPath = path.CGPath;
}

-(void)addGrayGradientShadow{
    // 0.8 is a good feeling shadowOpacity
    self.layer.shadowOpacity = 0.4;
    
    // The Width and the Height of the shadow rect
    CGFloat rectWidth = 10.0;
    CGFloat rectHeight = self.frame.size.height;
    
    // Creat the path of the shadow
    CGMutablePathRef shadowPath = CGPathCreateMutable();
    // Move to the (0, 0) point
    CGPathMoveToPoint(shadowPath, NULL, 0.0, 0.0);
    // Add the Left and right rect
    CGPathAddRect(shadowPath, NULL, CGRectMake(0.0-rectWidth, 0.0, rectWidth, rectHeight));
    CGPathAddRect(shadowPath, NULL, CGRectMake(self.frame.size.width, 0.0, rectWidth, rectHeight));
    
    self.layer.shadowPath = shadowPath;
    CGPathRelease(shadowPath);
    // Since the default color of the shadow is black, we do not need to set it now
    //self.layer.shadowColor = [UIColor blackColor].CGColor;
    
    self.layer.shadowOffset = CGSizeMake(0, 0);
    // This is very important, the shadowRadius decides the feel of the shadow
    self.layer.shadowRadius = 10.0;
}

@end
