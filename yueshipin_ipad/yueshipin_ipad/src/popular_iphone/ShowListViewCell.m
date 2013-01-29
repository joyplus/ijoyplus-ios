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

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0, 2, 320, 126)];
        [self addSubview:imageView_];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 113, 320, 15)];
        view.backgroundColor = [UIColor grayColor];
        view.alpha = 0.5;
        [self addSubview:view];
        nameLabel_ = [[UILabel alloc] initWithFrame:CGRectMake(0, 113, 320, 15)];
        nameLabel_.backgroundColor = [UIColor clearColor];
        nameLabel_.textColor = [UIColor whiteColor];
        nameLabel_.font = [UIFont systemFontOfSize:14];
        [self addSubview:nameLabel_];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
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
