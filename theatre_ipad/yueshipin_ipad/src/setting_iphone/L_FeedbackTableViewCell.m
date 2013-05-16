//
//  FeedbackTableViewCell.m
//  UMeng Analysis
//
//  Created by liuyu on 9/18/12.
//  Copyright (c) 2012 Realcent. All rights reserved.
//

#import "L_FeedbackTableViewCell.h"
@implementation L_FeedbackTableViewCell
@synthesize avatarImageView = avatarImageView_;
@synthesize dateLabel = dateLabel_;
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
        
        avatarImageView_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"feedBackhead.jpg"]];
        avatarImageView_.frame = CGRectMake(0, 0, 35, 35);
        [self.contentView addSubview:avatarImageView_];
        
        messageBackgroundView = [[UIImageView alloc] initWithFrame:self.textLabel.frame];
        messageBackgroundView.image = [[UIImage imageNamed:@"bubble"] stretchableImageWithLeftCapWidth:20 topCapHeight:20];
        [self.contentView insertSubview:messageBackgroundView belowSubview:self.textLabel];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect textLabelFrame = self.textLabel.frame;
    textLabelFrame.origin.x = 25;
    textLabelFrame.size.width = 250;
    
    CGSize labelSize = [self.textLabel.text sizeWithFont:[UIFont systemFontOfSize:14.0f]
                           constrainedToSize:CGSizeMake(250.0f, MAXFLOAT)
                               lineBreakMode:NSLineBreakByWordWrapping];
    
    textLabelFrame.size.height = labelSize.height + 6;
    self.textLabel.frame = CGRectMake(textLabelFrame.origin.x+32, textLabelFrame.origin.y+2, textLabelFrame.size.width, textLabelFrame.size.height);
    avatarImageView_.frame = CGRectMake(5, self.frame.size.height -35, 35, 35);
    messageBackgroundView.frame = CGRectMake(42, textLabelFrame.origin.y , labelSize.width + 30, labelSize.height + 12);;
}

@end
