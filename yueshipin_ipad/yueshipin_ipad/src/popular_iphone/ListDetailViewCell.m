//
//  ListDetailViewCell.m
//  yueshipin
//
//  Created by 08 on 12-12-24.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ListDetailViewCell.h"

@implementation ListDetailViewCell
@synthesize imageview = imageview_;
@synthesize label = label_;
@synthesize actors = actors_;
@synthesize area = area_;
@synthesize support = support_;
@synthesize addFav = addFav_;
@synthesize score = score_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, 112);
        UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
        frame.frame = CGRectMake(14, 15, 59, 87);
        [self addSubview:frame];
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(16, 17, 54, 81)];
        [self addSubview:self.imageview];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(82, 19, 170, 14)];
        self.label.font = [UIFont systemFontOfSize:15];
        [self addSubview:self.label];
        
        actors_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 42, 200, 12)];
        actors_.font = [UIFont systemFontOfSize:12];
        actors_.textColor = [UIColor grayColor];
        area_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 58, 170, 12)];
        area_.font = [UIFont systemFontOfSize:12];
        area_.textColor = [UIColor grayColor];
        [self addSubview:actors_];
        [self addSubview:area_];
        
        UIImageView *supportBg = [[UIImageView alloc] initWithFrame:CGRectMake(157, 76, 66, 21)];
        supportBg.image = [UIImage imageNamed:@"collect_number.png"];
        UIImageView *addFavBg = [[UIImageView alloc] initWithFrame:CGRectMake(231, 76, 66, 21)];
        addFavBg.image = [UIImage imageNamed:@"collect_number.png"];
        [self addSubview:supportBg];
        [self addSubview:addFavBg];
        
        support_ = [[UILabel alloc] initWithFrame:CGRectMake(193, 80, 30, 14)];
        support_.backgroundColor = [UIColor clearColor];
        support_.textColor = [UIColor grayColor];
        support_.font = [UIFont systemFontOfSize:10];
        support_.textAlignment = NSTextAlignmentLeft;
        addFav_ = [[UILabel alloc] initWithFrame:CGRectMake(268, 80, 30, 14)];
        addFav_.backgroundColor = [UIColor clearColor];
        addFav_.textColor = [UIColor grayColor];
        addFav_.font = [UIFont systemFontOfSize:10];
        addFav_.textAlignment = NSTextAlignmentLeft;
        
        UIImageView *supportLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_push.png"]];
        supportLogo.frame = CGRectMake(180, 79, 10, 14);
        UIImageView *addFavLogo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_collect.png"]];
        addFavLogo.frame = CGRectMake(253, 79, 15, 15);
        [self addSubview:supportLogo];
        [self addSubview:addFavLogo];
        [self addSubview:support_];
        [self addSubview:addFav_];
        
        score_ = [[UILabel alloc] initWithFrame:CGRectMake(256, 19, 49, 14)];
        score_.font = [UIFont systemFontOfSize:15];
        score_.textColor = [UIColor colorWithRed:56/255.0 green:104/255.0 blue:188/255.0 alpha: 1.0f];
        [self addSubview:score_];
        
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_numeral_watercress.png"]];
        logo.frame = CGRectMake(295, 19, 14, 14);
        [self addSubview:logo];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        line.frame = CGRectMake(0, 111, 320, 1);
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
