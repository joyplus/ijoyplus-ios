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
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15, 16, 57, 84)];
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
        
        UIImageView *supportBg = [[UIImageView alloc] initWithFrame:CGRectMake(82, 75, 65, 20)];
        supportBg.image = [UIImage imageNamed:@"tab2_television_list_recommend.png"];
        UIImageView *addFavBg = [[UIImageView alloc] initWithFrame:CGRectMake(157, 75, 65, 20)];
        addFavBg.image = [UIImage imageNamed:@"tab2_television_list_favorite.png"];
        [self addSubview:supportBg];
        [self addSubview:addFavBg];
        
        support_ = [[UILabel alloc] initWithFrame:CGRectMake(85, 81, 55, 10)];
        support_.backgroundColor = [UIColor clearColor];
        support_.font = [UIFont systemFontOfSize:12];
        support_.textAlignment = NSTextAlignmentCenter;
        addFav_ = [[UILabel alloc] initWithFrame:CGRectMake(163, 81, 55, 10)];
        addFav_.backgroundColor = [UIColor clearColor];
        addFav_.font = [UIFont systemFontOfSize:12];
        addFav_.textAlignment = NSTextAlignmentCenter;
        [self addSubview:support_];
        [self addSubview:addFav_];
        
        score_ = [[UILabel alloc] initWithFrame:CGRectMake(266, 19, 49, 14)];
        score_.font = [UIFont systemFontOfSize:15];
        score_.textColor = [UIColor colorWithRed:56/255.0 green:104/255.0 blue:188/255.0 alpha: 1.0f];
        [self addSubview:score_];
        
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
