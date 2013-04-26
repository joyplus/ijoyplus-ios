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
        self.backgroundColor = [UIColor clearColor];
        
        UIImageView *iconBgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab_list_moviecard.png"]];
        iconBgView.frame = CGRectMake(2, 12, 82, 111);
        [self addSubview:iconBgView];
        
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(7.5, 15, 68, 100)];
        [self addSubview:self.imageview];
        
        self.title = [[UILabel alloc] initWithFrame:CGRectMake(106, 18, 160, 14)];
        self.title.backgroundColor = [UIColor clearColor];
        self.title.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.title];
        
        self.labelOne = [[UILabel alloc] initWithFrame:CGRectMake(146, 42, 160, 14)];
        self.labelOne.backgroundColor = [UIColor clearColor];
        self.labelOne.font = [UIFont systemFontOfSize:12];
        self.labelOne.textColor = [UIColor grayColor];
        [self addSubview:self.labelOne];
        
        UIImageView *img1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_01.png"]];
        img1.frame = CGRectMake(125, 44, 13, 10);
        [self addSubview:img1];
        
        self.labelTwo = [[UILabel alloc] initWithFrame:CGRectMake(146, 65, 160, 14)];
        self.labelTwo.backgroundColor = [UIColor clearColor];
        self.labelTwo.font = [UIFont systemFontOfSize:12];
        self.labelTwo.textColor = [UIColor grayColor];
        [self addSubview:self.labelTwo];
        
        UIImageView *img2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_02.png"]];
        img2.frame = CGRectMake(125, 67, 13, 10);
        [self addSubview:img2];
        
        self.labelThree = [[UILabel alloc] initWithFrame:CGRectMake(146, 86, 160, 14)];
        self.labelThree.backgroundColor = [UIColor clearColor];
        self.labelThree.font = [UIFont systemFontOfSize:12];
        self.labelThree.textColor = [UIColor grayColor];
        [self addSubview:self.labelThree];
        
        UIImageView *img3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tab2_03.png"]];
        img3.frame = CGRectMake(125, 88, 13, 10);
        [self addSubview:img3];
        
        UILabel *labelFour = [[UILabel alloc] initWithFrame:CGRectMake(150, 100,160, 14)];
        labelFour.backgroundColor = [UIColor clearColor];
        labelFour.text = @"...";
        labelFour.textColor = [UIColor grayColor];
        [self addSubview:labelFour];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fengexian.png"]];
        line.frame = CGRectMake(0, 129, 320, 1);
        [self addSubview:line];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
