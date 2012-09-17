//
//  CustomBackButton.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-17.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "CustomBackButton.h"

#define MAX_BACK_BUTTON_WIDTH 160.0
@implementation CustomBackButton

- (id)initWith:(UIImage*)backButtonImage highlight:(UIImage*)backButtonHighlightImage leftCapWidth:(CGFloat)capWidth text:(NSString *)text
{
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    if (self) {
        // Create stretchable images for the normal and highlighted states
        UIImage* buttonImage = [backButtonImage stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
        UIImage* buttonHighlightImage = [backButtonHighlightImage stretchableImageWithLeftCapWidth:capWidth topCapHeight:0.0];
        
        // Create a custom button
        
        // Set the title to use the same font and shadow as the standard back button
        self.titleLabel.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.shadowOffset = CGSizeMake(0,-1);
        self.titleLabel.shadowColor = [UIColor darkGrayColor];
        
        // Set the break mode to truncate at the end like the standard back button
        self.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        
        // Inset the title on the left and right
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 6.0, 0, 3.0);
        
        // Make the button as high as the passed in image
        self.frame = CGRectMake(0, 0, 0, buttonImage.size.height);
        
        // Measure the width of the text
        CGSize textSize = [text sizeWithFont:self.titleLabel.font];
        // Change the button's frame. The width is either the width of the new text or the max width
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, (textSize.width + (capWidth * 1.5)) > MAX_BACK_BUTTON_WIDTH ? MAX_BACK_BUTTON_WIDTH : (textSize.width + (capWidth * 1.5)), self.frame.size.height);
        
        // Set the text on the button
        [self setTitle:text forState:UIControlStateNormal];
        
        // Set the stretchable images as the background for the button
        [self setBackgroundImage:buttonImage forState:UIControlStateNormal];
        [self setBackgroundImage:buttonHighlightImage forState:UIControlStateHighlighted];
        [self setBackgroundImage:buttonHighlightImage forState:UIControlStateSelected];
        
        // Add an action for going back
//        [self addTarget:hDelegate action:@selector(closeSelf) forControlEvents:UIControlEventTouchUpInside];
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

@end
