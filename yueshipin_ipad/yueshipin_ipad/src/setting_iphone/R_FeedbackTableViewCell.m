//
//  R_FeedbackTableViewCell.m
//  UMeng Analysis
//
//  Created by liuyu on 9/18/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "R_FeedbackTableViewCell.h"
#import "UIImageView+WebCache.h"
#import "ContainerUtility.h"
#import "CMConstants.h"
@implementation R_FeedbackTableViewCell
@synthesize avatarImageView = avatarImageView_;
@synthesize dateLabel = dateLabel_;
- (CGSize)stringCGSize:(NSString *)content font:(UIFont *)font width:(CGFloat)width {
    return [content sizeWithFont:font
               constrainedToSize:CGSizeMake(width, INT_MAX)
                   lineBreakMode:NSLineBreakByWordWrapping
    ];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = [UIFont systemFontOfSize:14.0f];
        self.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.textLabel.numberOfLines = 0;
        self.textLabel.textAlignment = NSTextAlignmentLeft;

        dateLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width/2 -75, 5, 150, 15)];
        dateLabel_.backgroundColor = [UIColor clearColor];
        dateLabel_.textColor = [UIColor grayColor];
        dateLabel_.font = [UIFont systemFontOfSize:13];
        dateLabel_.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:dateLabel_];
        
        avatarImageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 35, 35)];
        avatarImageView_.layer.borderWidth = 1;
        avatarImageView_.layer.borderColor = [[UIColor colorWithRed:231/255.0 green:230/255.0 blue:225/255.0 alpha: 1.0f] CGColor];
        NSString *avatarUrl = (NSString *)[[ContainerUtility sharedInstance]attributeForKey:kUserAvatarUrl];
        [avatarImageView_ setImageWithURL:[NSURL URLWithString:avatarUrl] placeholderImage:[UIImage imageNamed:@"self_icon"]];
        [self.contentView addSubview:avatarImageView_];
        
        messageBackgroundView = [[UIImageView alloc] initWithFrame:self.textLabel.frame];
        messageBackgroundView.image = [[UIImage imageNamed:@"bubbleself"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        [self.contentView insertSubview:messageBackgroundView belowSubview:self.textLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize size = [self stringCGSize:self.textLabel.text font:[UIFont systemFontOfSize:14.0] width:BubbleMaxWidth];

    CGRect textLabelFrame = CGRectMake(self.bounds.size.width - size.width - RightMargin, self.bounds.origin.y + 20, size.width, size.height);
    self.textLabel.frame = CGRectMake(textLabelFrame.origin.x -40, textLabelFrame.origin.y+5, textLabelFrame.size.width, textLabelFrame.size.height);
    avatarImageView_.frame = CGRectMake(320-43, self.frame.size.height -35, 35, 35);
    messageBackgroundView.frame = CGRectMake(textLabelFrame.origin.x - BubblePaddingLeft-40, textLabelFrame.origin.y - BubblePaddingTop+5, size.width + BubbleMarginHorizontal, size.height + BubbleMarginVertical);
}

@end
