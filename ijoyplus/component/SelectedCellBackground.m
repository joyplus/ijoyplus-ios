//
//  SelectedCellBackground.m
//  GoHappy
//
//  Created by li scott on 12-7-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SelectedCellBackground.h"
#import "Common.h"

@implementation SelectedCellBackground

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect paperRect = self.bounds; 
    CGFloat colors[] = {57/255.0, 59/255.0, 60/255.0, 1.0, 57/255.0, 59/255.0, 60/255.0, 1.0};
    drawLinearGradient(context, paperRect, colors);
}

@end
