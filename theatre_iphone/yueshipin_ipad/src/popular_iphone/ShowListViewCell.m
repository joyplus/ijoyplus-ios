//
//  ShowListViewCell.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "ShowListViewCell.h"

@implementation ShowListViewCell
@synthesize imageView = imageView_;
@synthesize nameLabel = nameLabel_;
@synthesize latest = latest_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 320, 78)];
        [self addSubview:imageView_];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 80, 320, 15)];
        view.backgroundColor = [UIColor grayColor];
        view.alpha = 0.5;
        [self addSubview:view];
        nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(5, 80, 125, 15)];
        nameLabel_.backgroundColor = [UIColor clearColor];
        nameLabel_.textColor = [UIColor whiteColor];
        nameLabel_.font = [UIFont systemFontOfSize:13];
        [self addSubview:nameLabel_];
        
        latest_ = [[UILabel alloc] initWithFrame:CGRectMake(135, 80, 190, 15)];
        latest_.backgroundColor = [UIColor clearColor];
        latest_.textColor = [UIColor whiteColor];
        latest_.font = [UIFont systemFontOfSize:13];
        [self addSubview:latest_];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        
        line.frame = CGRectMake(0, 95, 320, 1);
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
