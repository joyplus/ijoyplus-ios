//
//  RecordListCell.m
//  yueshipin
//
//  Created by 08 on 12-12-26.
//  Copyright (c) 2012年 joyplus. All rights reserved.
//

#import "RecordListCell.h"

@implementation RecordListCell
@synthesize titleLab = titleLab_;
@synthesize actors = actors_;
@synthesize date = date_;
@synthesize play = play_;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 296, 60);
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, 200, 15)];
        [self addSubview:self.titleLab];
        
        self.actors = [[UILabel alloc] initWithFrame:CGRectMake(12, 31, 200, 15)];
        self.actors.font = [UIFont systemFontOfSize:12];
        self.actors.textColor = [UIColor grayColor];
        [self addSubview:self.actors];
        
        date_ = [[UILabel alloc] initWithFrame:CGRectMake(12, 45, 200, 15)];
        date_.font = [UIFont systemFontOfSize:12];
        date_.textColor = [UIColor grayColor];
        [self addSubview:date_];
        
        play_ = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        play_.frame = CGRectMake(150, 20, 60, 30);
        [play_ setTitle:@"play" forState:UIControlStateNormal];
        [self addSubview:play_];
        
        UIImageView *line = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"list_fen_ge_xian.png"]];
        line.frame = CGRectMake(0, 59, 320, 1);
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
