//
//  SortedViewCell.m
//  yueshipin
//
//  Created by 08 on 12-12-25.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "SortedViewCell.h"

@implementation SortedViewCell
@synthesize imageview = imageview_;
@synthesize title = title_;
@synthesize labelOne = labelOne_;
@synthesize labelTwo = labelTwo_;
@synthesize labelThree = labelThree_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 15, 68, 100)];
        [self addSubview:self.imageview];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(126, 18, 160, 14)];
        [self addSubview:self.title];
        
        self.labelOne = [[UILabel alloc] initWithFrame:CGRectMake(126, 42, 160, 14)];
        [self addSubview:self.labelOne];
        
        self.labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(126, 65, 160, 14)];
        [self addSubview:self.labelTwo];
        
        self.labelThree = [[UILabel alloc] initWithFrame:CGRectMake(126, 86, 160, 14)];
        [self addSubview:self.labelThree];
        
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
