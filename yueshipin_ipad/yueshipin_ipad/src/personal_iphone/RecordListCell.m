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
@synthesize line = line_;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.titleLab = [[UILabel alloc] initWithFrame:CGRectMake(12, 14, 200, 15)];
        self.titleLab.font = [UIFont systemFontOfSize:14];
        self.titleLab.textColor = [UIColor colorWithRed:110.0/255 green:110.0/255 blue:110.0/255 alpha:1.0];
        titleLab_.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLab];
        
        self.actors = [[UILabel alloc] initWithFrame:CGRectMake(12, 31, 200, 15)];
        self.actors.font = [UIFont systemFontOfSize:12];
        self.actors.textColor = [UIColor grayColor];
        actors_.backgroundColor = [UIColor clearColor];
        [self addSubview:self.actors];
        
        date_ = [[UILabel alloc] initWithFrame:CGRectMake(12, 45, 200, 15)];
        date_.font = [UIFont systemFontOfSize:12];
        date_.textColor = [UIColor grayColor];
        date_.backgroundColor = [UIColor clearColor];
        [self addSubview:date_];
        
        play_ = [UIButton buttonWithType:UIButtonTypeCustom];
        play_.frame = CGRectMake(248,0, 47, 42);
        [play_ setBackgroundImage:[UIImage imageNamed:@"tab3_page1_icon_see.png"] forState:UIControlStateNormal];
        [self addSubview:play_];
        
        line_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fengexian.png"]];
        line_.frame = CGRectMake(0, 41, self.frame.size.width, 1);
        [self addSubview:line_];
        
        UIView *selectedBg = [[UIView alloc] initWithFrame:self.frame];
        selectedBg.backgroundColor = [UIColor colorWithRed:185.0/255 green:185.0/255 blue:174.0/255 alpha:0.4];
        self.selectedBackgroundView = selectedBg;
    }
    return self;
}

@end
