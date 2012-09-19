//
//  MyProfileCell.m
//  ijoyplus
//
//  Created by joyplus1 on 12-9-19.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "MyProfileCell.h"

@implementation MyProfileCell
@synthesize subtitleLabel;
@synthesize thirdTitleLabel;
@synthesize separatorImageBottom;
@synthesize avatarImageView;
@synthesize filmImageView;
@synthesize titleLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)layoutSubviews {
    // Layout separator
    self.separatorImageBottom.image = [UIImage imageNamed:@"black_separator"];
    [self.separatorImageBottom setFrame:CGRectMake( 0.0f, self.frame.size.height - 2.0f, self.frame.size.width, 2.0f)];
}

@end
