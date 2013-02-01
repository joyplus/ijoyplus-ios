//
//  CustomNavigationButton.m
//  yueshipin
//
//  Created by 08 on 13-2-1.
//  Copyright (c) 2013年 joyplus. All rights reserved.
//

#import "CustomNavigationButtonView.h"

@implementation CustomNavigationButtonView

@synthesize buttonLabel = buttonLabel_;
@synthesize button = button_;
@synthesize warningNumber = warningNumber_;

/**
 * @brief
 *
 * Detailed comments of this function
 * @param[in]
 * @param[out]
 * @return
 * @note
 */
- (id)init {
    self = [super initWithFrame:CGRectMake(0, 0, 56, 30)];
    
    
    if (self) {
        self.warningNumber = 0;
    }
    return self;
}

/**
 * @brief
 *
 * Detailed comments of this function
 * @param[in]
 * @param[out]
 * @return
 * @note
 */
- (id)initWithFrame:(CGRect)frame {
    
    
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

/**
 * @brief
 *
 * Detailed comments of this function
 * @param[in]
 * @param[out]
 * @return
 * @note
 */
- (void)initUI:(UINavigationController*)navigationController withText:(NSString*)text {
    
    self.button = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.button setEnabled:YES];
    [self.button setImage:[UIImage imageNamed:@"download_icon_s.png"] forState:UIControlStateNormal];
    //[self.button setImage:[UIImage imageNamed:@"download_icon_s.png"] forState:UIControlStateHighlighted];
    UIFont* font = [UIFont systemFontOfSize:13];
    
    self.button.frame =  CGRectMake(0,0,40,30);
    self.frame =  CGRectMake(0,0,40,30);
    UILabel* label= [[UILabel alloc] initWithFrame:CGRectMake(8, 0, 20, 28)];
    label.contentMode=UIControlContentHorizontalAlignmentCenter;
    label.contentMode=UIControlContentVerticalAlignmentCenter;
    label.textAlignment = UITextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.font = font;
    label.text = text;
    
    self.buttonLabel=label;
    
    [self addSubview:self.button];
    [self addSubview:self.buttonLabel];
}



- (void)setWarningNumber:(NSInteger)warningNumber{

    if (warningNumber > 0) {
        if (messageImage_ == nil) {
            messageImage_ = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 15,0,8,8)];
            messageImage_.backgroundColor = [UIColor clearColor];
            UIImage* image = [UIImage imageNamed:@"remind.png"];          
//          messageImage_.image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
            messageImage_.image = image;
            numLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0.0f,-2.0f, 14.0f, 14.0f)];
            numLabel_.backgroundColor = [UIColor clearColor];
            numLabel_.textAlignment = UITextAlignmentCenter;
            numLabel_.font = [UIFont systemFontOfSize:10];
            numLabel_.textColor = [UIColor whiteColor];
            [messageImage_ addSubview:numLabel_];
            [self addSubview:messageImage_];

        }
        // numLabel_.text = [NSString stringWithFormat:@"%d",warningNumber];
        
    }else{
        if (messageImage_ != nil) {
            //numLabel_.text = [NSString stringWithFormat:@"%d",warningNumber];
            [numLabel_ removeFromSuperview];
            numLabel_ = nil;
            [messageImage_ removeFromSuperview];
            messageImage_ = nil;
        }
    }
    warningNumber_ = warningNumber;
}
@end
