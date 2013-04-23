//
//  R_FeedbackTableViewCell.h
//  UMeng Analysis
//
//  Created by liuyu on 9/18/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import <UIKit/UIKit.h>

static int const RightMargin = 20;

static int const BubblePaddingLeft = 6;

static int const BubblePaddingTop = 3;

static int const BubbleMarginHorizontal = 20;

static int const BubbleMarginVertical = 10;

static int const BubbleMaxWidth = 250;

@interface R_FeedbackTableViewCell : UITableViewCell {
    
    UIImageView *messageBackgroundView;
    UIImageView *avatarImageView_;
    
}
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *dateLabel;
@end
