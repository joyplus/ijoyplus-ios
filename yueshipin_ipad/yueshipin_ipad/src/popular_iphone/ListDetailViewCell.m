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
        self.backgroundColor = [UIColor clearColor];
        self.frame = CGRectMake(0, 0, 320, 112);
        UIImageView *frame = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"listFrame.png"]];
        frame.frame = CGRectMake(14, 15, 59, 87);
        [self addSubview:frame];
        self.imageview = [[UIImageView alloc] initWithFrame:CGRectMake(16, 17, 54, 81)];
        [self addSubview:self.imageview];
        
        self.label = [[UILabel alloc] initWithFrame:CGRectMake(82, 19, 170, 14)];
        self.label.font = [UIFont systemFontOfSize:15];
        self.label.textColor = [UIColor colorWithRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0];
        self.label.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
        
        actors_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 42, 200, 12)];
        actors_.font = [UIFont systemFontOfSize:12];
        actors_.backgroundColor = [UIColor clearColor];
        actors_.textColor = [UIColor grayColor];
        area_ = [[UILabel alloc] initWithFrame:CGRectMake(82, 58, 170, 12)];
        area_.font = [UIFont systemFontOfSize:12];
        area_.textColor = [UIColor grayColor];
        area_.backgroundColor = [UIColor clearColor];
        [self addSubview:actors_];
        [self addSubview:area_];
        
        support_ = [UIButton buttonWithType:UIButtonTypeCustom];
        support_.backgroundColor = [UIColor clearColor];
        support_.frame = CGRectMake(82, 80, 66, 21);
       // [support_ setBackgroundImage:[UIImage imageNamed:@"collect_number.png"] forState:UIControlStateDisabled];
        support_.enabled = NO;
        [support_ setImage:[UIImage imageNamed:@"list_push.png"] forState:UIControlStateDisabled];
        [support_ setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        support_.titleLabel.font = [UIFont systemFontOfSize:12];
        support_.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        support_.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
        [self addSubview:support_];
        
        addFav_ = [UIButton buttonWithType:UIButtonTypeCustom];
        addFav_.backgroundColor = [UIColor clearColor];
        addFav_.frame = CGRectMake(156, 80, 66, 21);
        //[addFav_ setBackgroundImage:[UIImage imageNamed:@"collect_number.png"] forState:UIControlStateDisabled];
        addFav_.enabled = NO;
        [addFav_ setImage:[UIImage imageNamed:@"list_collect.png"] forState:UIControlStateDisabled];
        [addFav_ setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
        addFav_.titleLabel.font = [UIFont systemFontOfSize:12];
        addFav_.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 20);
        addFav_.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30);
        [self addSubview:addFav_];
            
        score_ = [[UILabel alloc] initWithFrame:CGRectMake(256, 19, 49, 14)];
        score_.font = [UIFont systemFontOfSize:15];
        score_.textColor = [UIColor orangeColor];
        score_.backgroundColor = [UIColor clearColor];
        [self addSubview:score_];
        
        UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_numeral_watercress.png"]];
        logo.frame = CGRectMake(295, 19, 14, 14);
        [self addSubview:logo];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fengexian.png"]];
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
