//
//  CustomCellBackground.m
//  CoolTable
//
//  Created by Ray Wenderlich on 9/29/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "CustomCellBackground.h"
#import "Common.h"

@implementation CustomCellBackground


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGRect paperRect = self.bounds;
    CGFloat colors[] = {241/255.0, 241/255.0, 241/255.0, 1.0, 241/255.0, 241/255.0, 241/255.0, 1.0};
    drawLinearGradient(context, paperRect, colors);
}

@end
