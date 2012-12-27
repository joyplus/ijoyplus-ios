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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, 112);
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(15, 16, 57, 84)];
        [self addSubview:self.imageview];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(82, 19, 170, 14)];
        [self addSubview:self.label];
        
        actors_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 42, 200, 12)];
        area_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 58, 170, 12)];
        [self addSubview:actors_];
        [self addSubview:area_];
        
        UIImageView *supportBg = [[UIImageView alloc] initWithFrame:CGRectMake(82, 75, 65, 20)];
        supportBg.backgroundColor = [UIColor blueColor];
        UIImageView *addFavBg = [[UIImageView alloc] initWithFrame:CGRectMake(157, 75, 65, 20)];
        addFavBg.backgroundColor = [UIColor blueColor];
        [self addSubview:supportBg];
        [self addSubview:addFavBg];
        
        support_ = [[UILabel alloc] initWithFrame:CGRectMake(85, 82, 55, 10)];
        addFav_ = [[UILabel alloc] initWithFrame:CGRectMake(163, 82, 55, 10)];
        [self addSubview:support_];
        [self addSubview:addFav_];
        
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
