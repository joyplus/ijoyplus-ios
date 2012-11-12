//
//  CustomCellBlackBackground
//  CoolTable
//
//  Created by Ray Wenderlich on 9/29/10.
//  Copyright 2010 Ray Wenderlich. All rights reserved.
//

#import "CustomCellBlackBackground.h"
#import "Common.h"

@implementation CustomCellBlackBackground


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext(); 
    CGRect paperRect = self.bounds;
    CGFloat colors[] = {25/255.0, 25/255.0, 25/255.0, 1.0, 25/255.0, 25/255.0, 25/255.0, 1.0};
    drawLinearGradient(context, paperRect, colors);
}

- (void)dealloc {
    
}


@end
